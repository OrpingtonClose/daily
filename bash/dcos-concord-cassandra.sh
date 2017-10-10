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

CASS_HOST=$(dcos cassandra endpoints node | jq -r '.vip' | cut -d':' -f1)
CASS_PORT=$(dcos cassandra endpoints node | jq -r '.vip' | cut -d':' -f2)

#ssh azureuser@$IP curl 10.0.0.4:9090/haproxy?stats > /tmp/haproxy_stats.html
#firefox /tmp/haproxy_stats.html

echo "CASS_HOST=$CASS_HOST" > sshenv

scp sshenv azureuser@$IP:~/.ssh/environment
ssh -i ~/.ssh/id_rsa azureuser@$IP
source ~/.ssh/environment
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install python-pip -y
export LC_ALL=C
sudo pip install cqlsh

cat > /tmp/setupcassandra.py <<EOL
from cassandra.cluster import Cluster
cluster = Cluster(["$CASS_HOST"])
session = cluster.connect()
session.execute("CREATE KEYSPACE demo WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 3 }")
session.execute("CREATE TABLE demo.map (key varchar, value varchar, PRIMARY KEY(key))")
EOL

python /tmp/setupcassandra.py  

#curl 10.0.0.4:9090/haproxy?stats

sudo docker pull concord/getting_started
sudo docker run -i -t concord/getting_started
mkdir deploy && cd !#:1
wget https://github.com/JakubPawlicki/daily/blob/master/python/concord/cassandra/first.py
wget https://github.com/JakubPawlicki/daily/blob/master/python/concord/cassandra/runner.bash

sudo pip install --upgrade concord
sudo apt-get install jq -y
curl https://raw.githubusercontent.com/JakubPawlicki/daily/master/python/concord/cassandra/first.json | sed "s/localhost:2181/$(cat /getting-started/.concord.cfg | jq -r '.zookeeper_hosts')/" | sed "s:/concord:$(cat /getting-started/.concord.cfg | jq -r '.zookeeper_path'):" > something.json
concord deploy something.json

concord runway --zk_path $(cat /getting-started/.concord.cfg | jq -r '.zookeeper_path') --zookeeper $(cat /getting-started/.concord.cfg | jq -r '.zookeeper_hosts')
#choose :
# 1
# 1
# yes
# demo
# map
# cassandra vip
# 5
