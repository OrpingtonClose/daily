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

is_local_app_set_in_docker=`sudo docker images | awk 'BEGIN {count=0} $1 == "azure-vode-front" {count++} END {print count}'`
if [ $is_local_app_set_in_docker -gt 0 ]; then
  local-app-setup
fi
unset is_local_app_set_in_docker

#create azure container registry
#https://docs.microsoft.com/en-gb/azure/aks/tutorial-kubernetes-prepare-acr
group_name=aResourceGroup
location=eastus
#indempotent?
if [ 0 -eq $(az group show --name $group_name -o tsv | wc -l) ]; then
  az group create --name $group_name --location $location
fi

container_registry_count=`az acr list -o tsv | wc -l`

if [ $container_registry_count -eq 0 ]; then
  acrName=aAcr`uuidgen | cut -c1-8`
  az acr create --resource-group $group_name --name $acrName --sku Basic
  return $acrName
else
  acrName=$(az acr list | jq -r '.[].name' | head -1) 
fi
  
sudo az acr login --name $acrName
login_server_of_acr=`az acr list -g $group_name --query "[].{arcLoginServer:loginServer}" -o tsv`
is_local_app_tagged_for_azure=$(sudo docker images | awk "BEGIN {count=0} \$1 == \"${login_server_of_acr}/azure-vote-front\",\$2 == \"v1\" {count++} END {print count}")
if [ $is_local_app_tagged_for_azure -eq 0 ]; then
  sudo docker tag azure-vote-front $login_server_of_acr/azure-vote-front:v1
fi

proper_registry_on_azure=`az acr repository list --name ${acrName} -o tsv | grep -F 'azure-vote-front' | wc -l`
proper_container_version=`az acr repository show-tags --name ${acrName} --repository azure-vote-front -o tsv | grep -F 'v1' | wc -l`
if [ $proper_registry_on_azure -eq 0 ] || [ $proper_container_version -eq 0 ]; then
  #one can put entire applications into the docker registry on azure. nice
  #would this work with gui applications?
  sudo docker push $login_server_of_acr/azure-vote-front:v1
fi

#acr_registry=`az acr list -o table | awk 'END {print $1}'`
#acr_repo=`az acr repository list --name $acr_registry --output table | awk 'END {print $1}'`
#az acr repository show-tags --name $acr_registry --repository $acr_repo --output table

cluster_name=aksclust`uuidgen | cut -c 1-8 | tr '[:upper:]' '[:lower:]'`

rbac_service_principal=$(az ad sp create-for-rbac)
echo $rbac_service_principal | jq
app_id=$(echo $rbac_service_principal | jq -r '.appId')
passw=$(echo $rbac_service_principal | jq -r '.password')
acr=$(az acr show --name $acrName -g $group_name)
acr_id=$(echo $acr | jq -r '.id')
echo $acr | jq
az role assignment create --assignee "$app_id" --role Reader --scope "$acr_id"

az aks create --name $cluster_name -g $group_name --node-count 1 --generate-ssh-keys --service-principal $app_id --client-secret "$passw"

#doesnt work. better to set up kubernetes on raw vms
#error:
#Deployment failed. Correlation ID: 54ad6991-d903-4d54-be4d-262d89e493b6. getting current state of the cluster returned an error:
# compute.VirtualMachinesClient#List: Failure responding to request: StatusCode=401 -- Original Error: autorest/azure: Service returned an error. Status=401 Code="InvalidAuthenticationToken" Message="The received access token is not valid: at least one of the claims 'puid' or 'altsecid' or 'oid' should be present. If you are accessing as application please make sure service principal is properly created in the tenant."
# o

