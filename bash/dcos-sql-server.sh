GROUP=dcos-test
NAME=concord-dcos

if [[ -v AZ_AD_ID ]] && [[ -v AZ_AD_PASS ]] && [[ -v AZ_AD_TENANT ]]
then
  az login --service-principal -u $AZ_AD_ID --password $AZ_AD_PASS --tenant $AZ_AD_TENANT
else
  az login
fi

az group create --name $GROUP --location westeurope
az acs create --orchestrator-type dcos --resource-group $GROUP --name $NAME --generate-ssh-keys
IP=$(az network public-ip list --resource-group $GROUP --query "[?contains(name,'dcos-master')].[ipAddress]" -o tsv)
sudo ssh -i ~/.ssh/id_rsa -fNL 85:localhost:80 -p 2200 azureuser@$IP
#firefox localhost:85

sudo sh -c "/root/bin/az acs dcos install-cli"

dcos config set core.dcos_url http://localhost:85

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
