# https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest

# manual login
az login

# delete all previous active directory applications applications
az ad app list | jq -r '.[].appId' | awk '{system("az ad app delete --id "$1)}' 

echo "type the application name"
read APP_NAME
echo "type the password for your application"
read APP_PASSWORD

RESPONSE_JSON=az as sp create-for-rbac --name $APP_NAME --password $APP_PASSWORD

echo "export AZ_AD_ID=$(echo $JSON | jq -r '.appId')" >> ~/.bashrc
echo "export AZ_AD_PASS=$(echo $JSON | jq -r '.password')" >> ~/.bashrc
echo "export AZ_AD_TENANT=$(az account show | jq -r '.tenantId')" >> ~/.bashrc
source ~/.bashrc

az logout

az login --service-principal -u $AZ_AD_ID --password $AZ_AD_PASS --tenant $AZ_AD_TENANT
