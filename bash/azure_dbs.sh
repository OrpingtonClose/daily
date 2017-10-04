az login --service-principal -u $AZ_AD_ID --password $AZ_AD_PASS --tenant $AZ_AD_TENANT

echo "export AZ_DATABASE_PASS=$(apg -m 14 -x 14 -M SNCL | head -n 1)" >> ~/.bashrc
echo "export AZ_DATABASE_ADMIN=orpington" >> ~/.bashrc
source ~/.bashrc
export EXTERNAL_IP=`curl -s http://whatismyip.akamai.com/`
GROUP=databases
LOCATION=westeurope
az group delete --name $GROUP --yes

az group create --name databases --location $LOCATION

#for db_system in sql mysql postgres
for db_system in sql
do 
  az $db_system server create --name pysparksrv$db_system --admin-user $AZ_DATABASE_ADMIN --admin-password $AZ_DATABASE_PASS --location $LOCATION --resource-group $GROUP
  az $db_system server firewall-rule create --end-ip-address $EXTERNAL_IP --start-ip-address $EXTERNAL_IP --resource-group $GROUP --server pysparksrv$db_system --name pysparkrule$db_system
  az $db_system db create --name pysparkdb$db_system --resource-group $GROUP --server pysparksrv$db_system
done
