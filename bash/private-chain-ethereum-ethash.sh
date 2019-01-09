BASEDIR=$PWD

#https://tecadmin.net/install-go-on-ubuntu/
wget https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz
sudo tar -xvf go1.10.3.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo mv go /usr/local/

cd $BASEDIR
git clone https://github.com/ethereum/go-ethereum
cd $BASEDIR/go-ethereum
make geth
cp $BASEDIR/go-ethereum/build/bin/geth $BASEDIR/geth

cd $BASEDIR
for n in {1..3}
do yes '' | $BASEDIR/geth --datadir $BASEDIR account import <(openssl ecparam -name secp256k1 -genkey -noout | openssl ec -text -noout 2> /dev/null | grep priv -A 3 | tail -n -3 | tr -d '\n[:space:]:' | sed 's/^00//') 
done

cat > $BASEDIR/genesis.json <<EOF
{
  "alloc": {},
  "config": {
    "chainId": 12736,
    "homesteadBlock": 1,
    "eip150Block": 2,
    "eip150Hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "eip155Block": 3,
    "eip158Block": 3,
    "byzantiumBlock": 4
  },
  "nonce": "0x0",
  "timestamp": "0x5c2cadfa",
  "gasLimit": "0x47b760",
  "difficulty": "0x1",
  "mixHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "coinbase": "0x0000000000000000000000000000000000000000",
  "number": "0x0",
  "gasUsed": "0x0",
  "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000"
}
EOF

for address in `ls $BASEDIR/keystore | rev | cut -c1-40 | rev`
do  json=$(cat $BASEDIR/genesis.json)
    echo $json | jq ".alloc.\"0x$address\" = {\"balance\": \"1000000000000000000000000\"}" > genesis.json
done

for n in {1..3} 
do mkdir -p $BASEDIR/node$n/keystore
   cp $BASEDIR/keystore/* $BASEDIR/node$n/keystore/
   cd $BASEDIR/node$n
   $BASEDIR/geth --datadir=$BASEDIR/node$n init $BASEDIR/genesis.json
done

cd $BASEDIR
PORTS=(9001 9002 9003)
for n in {1..3} 
do port=${PORTS[$(($n-1))]}
NODE_NAME="geth-$port"
xterm -T "geth [:]:$port" -bg black -fg white -e "cd $BASEDIR; geth --ethstats '$NODE_NAME:nothing@ws://localhost:3000' --verbosity 4 --nodiscover --networkid 12736 --datadir=$BASEDIR/node$n --rpc --rpcport=$port --rpccorsdomain=\"*\" --port=0 --rpcapi admin,db,debug,eth,miner,net,personal,shh,txpool,web3 --port=0 --mine --unlock 0x$address --password=<(echo \"\") --ipcpath \"$BASEDIR/node$n/test.ipc\"; sleep 10" &
done

#https://github.com/ethereum/go-ethereum/wiki/Management-APIs
:> $BASEDIR/static-nodes.json
for n in {1..3} 
do curl -s -H "Content-Type: application/json" -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"admin_nodeInfo\",\"params\":[],\"id\":$n}" http://localhost:900$n | jq -r '.result.enode' | tee -a static-nodes.json
done

for n in {1..3}
do mkdir -p $BASEDIR/node$n/geth
   cp $BASEDIR/static-nodes.json $BASEDIR/node$n/geth/
   curl -s -H "Content-Type: application/json" -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"admin_nodeInfo\",\"params\":[],\"id\":$n}" http://localhost:900$n | jq -r '.result.enode' | tee -a $BASEDIR/static-nodes.json
   cat $BASEDIR/static-nodes.json | xargs -n 1 -I {} curl -s -H "Content-Type: application/json" -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"admin_addPeer\",\"params\":[\"{}\"],\"id\":$n}" http://localhost:900$n
done

echo Block number: $(($(curl -s -H "Content-Type: application/json" -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_blockNumber\",\"params\":[],\"id\":1}" http://localhost:9001 | jq -r '.result')))

#https://ethereum.stackexchange.com/questions/24911/geth-warning-stats-login-failed#29650
git clone https://github.com/cubedro/eth-netstats
cd eth-netstats
npm install
sudo npm install -g grunt-cli
grunt
xterm -T "ethstats" -bg black -fg white -e "cd $PWD; WS_SECRET=nothing npm start; sleep 10" &

xdg-open http://localhost:3000
