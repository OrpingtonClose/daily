GROUP=dcos-test
NAME=concord-dcos

apt-get update && apt-get install -y libssl-dev libffi-dev python-dev build-essential
curl -L https://aka.ms/InstallAzureCli | bash
exec -l $SHELL
sudo -i
az acs dcos install-cli
exit

az login
az group create --name $GROUP --location westeurope
az acs create --orchestrator-type dcos --resource-group $GROUP --name $concord-dcos --generate-ssh-keys
IP=$(az network public-ip list --resource-group $GROUP --query "[?contains(name,'dcos-master')].[ipAddress]" -o tsv)
sudo ssh -i ~/.ssh/id_rsa -fNL 80:localhost:80 -p 2200 azureuser@$IP

dcos config set core.dcos_url http://localhost
# create json
cat >nginx-public.json <<EOL
{
  "id": "demo-app",
  "cmd": null,
  "cpus": 1,
  "mem": 32,
  "disk": 0,
  "instances": 1,
  "container": {
    "docker": {
      "image": "nginx",
      "network": "BRIDGE",
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp",
          "name": "80",
          "labels": null
        }
      ]
    },
    "type": "DOCKER"
  },
  "acceptedResourceRoles": [
    "slave_public"
  ]
}
EOL

dcos marathon app add nginx-public.json 
# wait till the deployment is finished
dcos marathon app list

firefox $(az network public-ip list --resource-group $GROUP --query "[?contains(name,'dcos-agent')].[ipAddress]" -o tsv)

#az group delete --name $GROUP --no-wait

