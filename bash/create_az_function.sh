#https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-azure-function-azure-cli
LOC=westeurope
RESGR=for_functions
STOR=71a03c95
NAME=2a7e74a4-aeca-427f-a6c5-f77720c0e73a

az group create --name $RESGR --location $LOC

az storage account create --name $STOR -g $RESGR --location $LOC --sku Standard_LRS

az functionapp create --deployment-source-url https://github.com/Azure-Samples/functions-quickstart -g $RESGR --consumption-plan-location $LOC --name $NAME --storage-account $STOR

curl http://$NAME.azurewebsites.net/api/HttpTriggerJS1?name=$(whoami)

az group delete -n $RESGR
