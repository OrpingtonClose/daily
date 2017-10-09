GROUP=dcos-test
NAME=concord-dcos

if [[ -v AZ_AD_ID ]] && [[ -v AZ_AD_PASS ]] && [[ -v AZ_AD_TENANT ]]
then
  az login --service-principal -u $AZ_AD_ID --password $AZ_AD_PASS --tenant $AZ_AD_TENANT
else
  az login
fi

az group create --name $GROUP --location westeurope
az acs create --orchestrator-type dcos --resource-group $GROUP --name $NAME --generate-ssh-keys --agent-count 3 --agent-vm-size Standard_DS11_v2
IP=$(az network public-ip list --resource-group $GROUP --query "[?contains(name,'dcos-master')].[ipAddress]" -o tsv)
sudo ssh -i ~/.ssh/id_rsa -fNL 85:localhost:80 -p 2200 azureuser@$IP
#firefox localhost:85

if [[ -z "$(which dcos)" ]]
then 
  sudo sh -c "/root/bin/az acs dcos install-cli"
fi

dcos config set core.dcos_url http://localhost:85

dcos package install marathon-lb --yes
dcos package install concord --yes
dcos package install cassandra --yes

CASSANDRA_VIP=dcos cassandra endpoints node | jq -r '.vip'

ssh azureuser@$IP curl 10.0.0.4:9090/haproxy?stats > /tmp/haproxy_stats.html
firefox /tmp/haproxy_stats.html

ssh -i ~/.ssh/id_rsa azureuser@$IP
curl 10.0.0.4:9090/haproxy?stats

sudo docker pull concord/getting_started
sudo docker run -i -t concord/getting_started
mkdir deploy && cd !#:1
wget https://raw.githubusercontent.com/JakubPawlicki/daily/master/python/concord/hello-world/something.json
wget https://raw.githubusercontent.com/JakubPawlicki/daily/master/python/concord/hello-world/something.py
wget https://raw.githubusercontent.com/JakubPawlicki/daily/master/python/concord/hello-world/runner.bash

sudo pip install --upgrade concord
sudo apt-get install jq -y
url https://raw.githubusercontent.com/JakubPawlicki/daily/master/python/concord/hello-world/something.json | sed "s/localhost:2181/$(cat /getting-started/.concord.cfg | jq -r '.zookeeper_hosts')/" | sed "s:/concord:$(cat /getting-started/.concord.cfg | jq -r '.zookeeper_path'):" > something.json
concord deploy something.json

sudo apt-get install python-zookeeper

#LB=$(az network lb list | jq -r ".[] | select( .name | contains(\"agent\")).name")
#az network lb rule create --name ${LB}cass --resource-group $GROUP --protocol Tcp --lb-name $LB --frontend-port 9042 --backend-port 9042
#http://$YOUR_PUBLIC_NODE_IP_ADDRESS:9090/haproxy?stats
#http://$IP:9090/haproxy?stats



#dcos package install --yes marathon-lb

#dcos marathon app add https://dcos.io/docs/1.7/usage/tutorials/marathon/stateful-services/postgres.marathon.json

#NSG_JSON=$(az network nsg list | jq -r ".[] | select( .name | contains(\"public\"))")
#NSG=$(echo $NSG_JSON | jq -r '.name')

#az network nsg rule create -g $GROUP --nsg-name $NSG -n externaldcosaccess --priority 101
#https://docs.microsoft.com/en-us/azure/container-service/dcos-swarm/container-service-enable-public-access
#https://github.com/dcos/examples/tree/master/sqlserver/1.8
