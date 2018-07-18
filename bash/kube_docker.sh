#Ubuntu 17.10
#installing docker
#https://askubuntu.com/questions/909691/how-to-install-docker-on-ubuntu-17-04#909915
if [ -z "`apt list --installed | grep 'docker-ce'`" ]; then
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7EA0A9C3F273FCD8
  echo 'deb [arch=amd64] https://download.docker.com/linux/ubuntu zesty stable' | sudo tee /etc/apt/sources.list.d/docker.list
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7EA0A9C3F273FCD8
  sudo apt-get update
  sudo apt-get install docker-ce -y
  sudo apt install docker-compose -y
fi
if [ -z "`apt list --installed | grep 'git'`" ]; then
  sudo apt-get install git -y
fi
#https://docs.microsoft.com/en-gb/azure/aks/tutorial-kubernetes-prepare-app
rm -rf azure-voting-app-redis
git clone https://github.com/Azure-Samples/azure-voting-app-redis.git
cd azure-voting-app-redis
sed -i '/^version/ s/3/2/' docker-compose.yaml
sudo docker-compose up -d
firefox "http://localhost:8080"
read sss
sudo docker-compose stop
sudo docker-compose down
cd ..
rm -rf azure-voting-app-redis

