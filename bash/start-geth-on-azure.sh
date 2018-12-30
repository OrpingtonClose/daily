az login
az group create -n forropsten -l northeurope
RES=$(az vm create --name forropsten -g forropsten --image UbuntuLTS --admin-username orpington --generate-ssh-keys)

IP=$(echo $RES | jq '.publicIpAddress' -r)

ssh orpington@$IP

sudo apt-add-repository ppa:ethereum/ethereum
sudo apt-get update
sudo apt-get install ethereum -y

cat | sudo tee /lib/systemd/system/geth-testnet.service <<EOF
[Unit]
Description=geth full node
After=network.target
After=syslog.target

[Install]
WantedBy=multi-user.target

[Service]
ExecStart=/usr/bin/geth --rpc --rpcport "8545" --rpcaddr "127.0.0.1" --rpccorsdomain "*" --testnet --cache=4096 --verbosity=5
EOF

systemctl start geth-testnet

journalctl -u geth-testnet -f

#return to origin machine
ssh -f -N -L 9545:localhost:8545 orpington@40.127.106.43
curl -H "Content-Type: application/json" -X POST --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":67}' http://127.0.0.1:9545
