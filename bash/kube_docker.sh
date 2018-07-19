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
distro_short_codename=$(lsb_release -cs)
repo_string="deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $distro_short_codename main"
recursively_look_for_fixed_strings_in_files="`grep -Frl \"$repo_string\" /etc/apt/{sources.list,sources.list.d}`"
if [ -z "$recursively_look_for_fixed_strings_in_files" ]; then
  if test -z "`dpkg -L 'apt-transport-https'`"; then sudo apt-get install apt-transport-https -y ; fi
  echo "$repo_string" | sudo tee sudo tee /etc/apt/sources.list.d/azure-cli.list
  if test -z "`dpkg -L 'curl'`"; then sudo apt-get install curl -y ; fi
  curl -L https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add 
  sudo apt-get update
  sudo apt-get install azure-cli -y
fi

function local-app-setup() {
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
}

local-app-setup
#create azure container registry
#https://docs.microsoft.com/en-gb/azure/aks/tutorial-kubernetes-prepare-acr
group_name=aResourceGroup
location=eastus
acrName=aAcr`uuidgen | cut -c1-8`
az group create --name $group_name --location $location
az acr create --resource-group $group_name --name $acrName --sku Basic
sudo az acr login --name $acrName
login_server_of_acr=`az acr list -g $group_name --query "[].{arcLoginServer:loginServer}" -o tsv`
sudo docker tag azure-vote-front $login_server_of_acr/azure-vote-front:v1
#one can put entire applications into the docker registry on azure. nice
#would this work with gui applications?
sudo docker push $login_server_of_acr/azure-vote-front:v1
acr_registry=`az acr list -o table | awk 'END {print $1}'`
acr_repo=`az acr repository list --name $acr_registry --output table` | awk 'END {print $1}'`
az acr repository show-tags --name $acr_registry --repository $acr_repo --output table


