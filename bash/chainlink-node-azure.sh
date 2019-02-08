#https://medium.com/chainlink/running-a-chainlink-node-for-the-first-time-4988518c95d2
az login
GROUP=chainlinkropsten
VMNAME=clnode
if [ "$(az group list | jq -r '.[].name' | grep $GROUP | wc -l)" -eq "1" ]; then
    az group delete -n $GROUP --yes
fi
az group create -n $GROUP -l northeurope
RES=$(az vm create --name $VMNAME -g $GROUP --image UbuntuLTS --admin-username orpington --generate-ssh-keys)

IP=$(echo $RES | jq '.publicIpAddress' -r)

sudo ssh -i ~/.ssh/id_rsa -fNL 6688:localhost:6688 orpington@$IP
xdg-open http://localhost:6688

ssh orpington@$IP

# https://www.vultr.com/docs/installing-docker-ce-on-ubuntu-16-04
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce
sudo adduser user
sudo usermod -aG docker user
sudo systemctl restart docker
sudo docker info

sudo docker run hello-world
sudo systemctl enable docker

sudo docker pull ethereum/client-go:stable
mkdir ~/.geth-ropsten
sudo docker run --name eth -p 8546:8546 -v ~/.geth-ropsten:/geth -d \
       ethereum/client-go:stable --testnet --syncmode light --ws \
       --wsaddr 0.0.0.0 --wsorigins="*" --datadir /geth

#another window

sudo apt-get install -y nmap
sudo nmap localhost -p0-10000


sudo apt-add-repository ppa:ethereum/ethereum
sudo apt-get update
sudo apt-get install ethereum -y

geth attach ws://localhost:8546 -exec "eth.protocolVersion"

sudo docker pull smartcontract/chainlink:latest
mkdir ~/.chainlink-ropsten

echo "ROOT=/chainlink
LOG_LEVEL=debug
ETH_URL=ws://eth:8546
ETH_CHAIN_ID=3
MIN_OUTGOING_CONFIRMATIONS=2
MIN_INCOMING_CONFIRMATIONS=0
LINK_CONTRACT_ADDRESS=0x20fe562d797a42dcb3399062ae9546cd06f63280
CHAINLINK_TLS_PORT=0
CHAINLINK_DEV=true
ALLOW_ORIGINS=*" > .env

exit


sudo docker run --link eth -p 6688:6688 \
           -v ~/.chainlink-ropsten:/chainlink \
           -it --env-file=.env \
           smartcontract/chainlink n

