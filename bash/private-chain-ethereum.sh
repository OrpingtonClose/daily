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

mkdir testgeth 
cd testgeth
mkdir chaindata
cat > genesis.json <<EOF
{
  "coinbase": "0x0000000000000000000000000000000000000001",
  "difficulty": "0x20000",
  "extraData": "0x0000000000000000000000000000000000000000",
  "gasLimit": "0x8000000",
  "nonce": "0x0000000000000042",
  "mixHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "timestamp": "0x00",
  "alloc": {},
  "config": {
    "chainId": 155,
    "homesteadBlock": 0,
    "eip155Block": 0,
    "eip158Block": 0
  }
}
EOF
geth --datadir=./chaindata init genesis.json
kill `lsof -n -i UDP:30303 | awk '{if (NR > 1) print $2}'`
geth --datadir=./chaindata --rpc --rpccorsdomain="*" --ipcpath "$(pwd)/test.ipc" 1>/dev/null 2>/dev/null &
Mist --rpc "$(pwd)/test.ipc" 1>/dev/null 2>/dev/null &
geth attach ipc:$(pwd)/test.ipc

