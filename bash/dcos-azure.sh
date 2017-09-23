GROUP=dcos-test
NAME=concord-dcos

apt-get update && apt-get install -y libssl-dev libffi-dev python-dev build-essential
curl -L https://aka.ms/InstallAzureCli | bash
exec -l $SHELL
sudo -i
az acs dcos install-cli
exit

#az login
az login --service-principal -u $AZ_AD_ID --password $AZ_AD_PASS --tenant $AZ_AD_TENANT
az group create --name $GROUP --location westeurope
az acs create --orchestrator-type dcos --resource-group $GROUP --name $NAME --generate-ssh-keys
IP=$(az network public-ip list --resource-group $GROUP --query "[?contains(name,'dcos-master')].[ipAddress]" -o tsv)
sudo ssh -i ~/.ssh/id_rsa -fNL 85:localhost:80 -p 2200 azureuser@$IP
firefox localhost:85

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

# loab balancer
# https://docs.microsoft.com/en-us/azure/container-service/dcos-swarm/container-service-load-balancing
dcos package install marathon-lb 
FQDN_OF_DCOS_AGENT=$(az acs list --resource-group $GROUP --query "[0].agentPoolProfiles[0].fqdn" --output tsv)
cat > hello-web.json <<EOL
{
  "id": "web",
  "container": { "type": "DOCKER",
                 "docker": { "image": "yeasy/simple-web",
                             "network": "BRIDGE",
                             "portMappings": [ { "hostPort": 0, 
                                                 "containerPort": 80, 
                                                 "servicePort": 10000 } ],
                             "forcePullImage":true } },
  "instances": 3,
  "cpus":0.1,
  "mem": 65,
  "healthChecks": [{ "protocol": "HTTP",
                     "path": "/",
                     "portIndex": 0,
                     "timeoutSeconds": 10,
                     "gracePeriodSeconds": 10,
                     "intervalSeconds": 2,
                     "maxConsecutiveFailure": 10 }],
  "labels":{ "HAPROXY_GROUP":"external",
             "HAPROXY_0_VHOST":"$FQDN_OF_DCOS_AGENT",
             "HAPROXY_0_MODE":"http" } }
EOL

dcos marathon app add hello-web.json
firefox $FQDN_OF_DCOS_AGENT






