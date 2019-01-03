if [[ -n "$(which geth)" ]]
then
  sudo apt-add-repository ppa:ethereum/ethereum
  sudo apt-get update -y && apt-get upgrade -y
  sudo apt-get install ethereum -y
fi

if [[ -n "$(which Mist)" ]]
then
  wget https://github.com/ethereum/mist/releases/download/v0.8.3/Mist-linux64-0-8-3.deb
  sudo dpkg --install Mist-linux64-0-8-3.deb
  rm Mist-linux64-0-8-3.deb
fi

rm -rf testgeth
mkdir testgeth 
cd testgeth
for n in {1..3}
do yes '' | geth --datadir . account import <(openssl ecparam -name secp256k1 -genkey -noout | openssl ec -text -noout 2> /dev/null | grep priv -A 3 | tail -n -3 | tr -d '\n[:space:]:' | sed 's/^00//') 
done

cat > genesis.json <<EOF
{
  "alloc": {},
  "config": {
    "chainId": 12736,
    "homesteadBlock": 1,
    "eip150Block": 2,
    "eip150Hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "eip155Block": 3,
    "eip158Block": 3,
    "byzantiumBlock": 4,
    "clique": {
      "period": 15,
      "epoch": 30000
    }
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

for address in `ls ./keystore | rev | cut -c1-40 | rev`
do  json=$(cat genesis.json)
    echo $json | jq ".alloc.\"0x$address\" = {\"balance\": \"1000000000000000000000000\"}" > genesis.json
done
json=$(cat genesis.json)
echo $json | jq ".extraData = \"0x0000000000000000000000000000000000000000000000000000000000000000${address}0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000\"" > genesis.json

for n in {1..3} 
do mkdir -p node$n/keystore
   cp keystore/* node$n/keystore/
   cp genesis.json node$n/
   geth --datadir=node$n init node$n/genesis.json
done

ps aux | awk '$11 == "geth" {print $2}' | xargs -n 1 kill
ps aux | awk '$11 == "bootnode" {print $2}' | xargs -n 1 kill

#bootnode -genkey boot.key
#bootnode -nodekey boot.key -verbosity 9 -addr :30310 &

for n in {1..3} 
#do nohup geth --networkid 12736 --datadir=node$n --bootnodes "enode://3b3e3a29ca5e9aade275f6c51e82ae644cad89209c7c80a3bde9dd0b522382cbb6ba3bc3c1c2bcb529b3ef129ea3633a11f396c9811f8a0601ab73a0131f5206@[::]:30310" --rpc --rpccorsdomain="*" --rpcport=900$n --port=0 --mine --unlock 0x$address --password=<(echo "") --ipcpath "$(pwd)/node$n/test.ipc" &
do xterm -bg black -fg white -e "geth --verbosity 5 --nodiscover --networkid 12736 --datadir=node$n --rpc --rpccorsdomain=\"*\" --rpcport=900$n --port=0 --rpcapi admin,db,debug,eth,miner,net,personal,shh,txpool,web3 --port=0 --mine --unlock 0x$address --password=<(echo \"\") --ipcpath \"$(pwd)/node$n/test.ipc\"" &
done

#https://github.com/ethereum/go-ethereum/wiki/Management-APIs

:> static-nodes.json
for n in {1..3} 
do curl -s -H "Content-Type: application/json" -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"admin_nodeInfo\",\"params\":[],\"id\":$n}" http://localhost:900$n | jq -r '.result.enode' | tee -a static-nodes.json
done

for n in {1..3}
do mkdir -p node$n/geth
    cp static-nodes.json node$n/geth/
    curl -s -H "Content-Type: application/json" -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"admin_nodeInfo\",\"params\":[],\"id\":$n}" http://localhost:900$n | jq -r '.result.enode' | tee -a static-nodes.json
    cat static-nodes.json | xargs -n 1 -I {} curl -s -H "Content-Type: application/json" -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"admin_addPeer\",\"params\":[\"{}\"],\"id\":$n}" http://localhost:900$n
done