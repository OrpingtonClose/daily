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
    "chainId": 52813,
    "homesteadBlock": 1,
    "eip150Block": 2,
    "eip150Hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "eip155Block": 3,
    "eip158Block": 3,
    "byzantiumBlock": 4,
    "ethash": {}
  },
  "nonce": "0x0",
  "timestamp": "0x5c2cedb0",
  "extraData": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "gasLimit": "0x47b760",
  "difficulty": "0x80000",
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

geth --datadir=. init genesis.json

ps aux | awk '$11 == "geth" {print $2}' | xargs -n 1 kill

ps aux | grep node

xterm -bg black -fg white -e "geth --networkid 52813 --datadir=. --rpc --rpccorsdomain=\"*\" --mine --unlock 0x$address --password=<(echo \"\") --ipcpath \"$(pwd)/test.ipc\"" &

#
mist --rpc "$(pwd)/test.ipc"
#geth attach ipc:$(pwd)/test.ipc
#--unlock 0x$address --password=<(echo "")
echo $address
for n in {1..3}
do curl -H "Content-Type: application/json" -X POST --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":67}' http://localhost:900$n
done

for n in {1..3}
do curl -H "Content-Type: application/json" -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":["latest"],"id":1}' http://localhost:900$n
done

curl -H "Content-Type: application/json" -X POST --data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' http://localhost:9001

curl -H "Content-Type: application/json" -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' http://localhost:8545


for acc in $(curl -H "Content-Type: application/json" -X POST --data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' http://localhost:8545 | jq -r '.result[]')
do curl -H "Content-Type: application/json" -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getBalance\",\"params\":[\"$acc\", \"latest\"],\"id\":1}" http://localhost:8545
done

mist --rpc=http://localhost:8545

puppethherp
