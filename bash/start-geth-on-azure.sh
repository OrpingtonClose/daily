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
ExecStart=/usr/bin/geth --testnet --cache=4096 --verbosity=5
EOF

systemctl start geth-testnet

journalctl -u geth-testnet -f