#install docker
sudo rm -rf /var/lib/docker
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get -y install docker-ce

sudo curl -L https://github.com/docker/compose/releases/download/1.24.0-rc1/docker-compose-`uname -s`-`uname -m` -o docker-compose
sudo chmod +x docker-compose

while read line 
do sudo cp docker-compose $line
done < <(which -a docker-compose)

sudo docker login

#didnt work
git clone https://github.com/blk-io/blk-explorer-free.git
cd blk-explorer-free
git pull
NODE_ENDPOINT=http://localhost:8001 docker-compose up 
sudo docker stop blk-free-mongodb
sudo docker rm blk-free-mongodb
xdg-open http://localhost:5000

docker exec -it <container name> /bin/bash 

git clone https://github.com/blk-io/epirus.git
cd epirus
./epirus.sh