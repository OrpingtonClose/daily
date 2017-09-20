GROUP_NAME=test-webapp
LOCATION="West Europe"
APP_SERVICE_PLAN_NAME="myAppServicePlan"
APP_NAME="test-wiki-app"
DEPLOY_USERNAME=$AZURE_WEBAPP_DEPLOY_USER
DEPLOY_PASS=$AZURE_WEBAPP_DEPLOY_PASS

#as login
git clone https://github.com/JakubPawlicki/weather-check.git
cd weather-check
sudo pip install -r requirements.txt
az webapp deployment user set --user-name $DEPLOY_USERNAME --password $DEPLOY_PASS
az group create --name $GROUP_NAME --location $LOCATION
az appservice plan create --name $APP_SERVICE_PLAN_NAME --resource-group $GROUP_NAME --sku FREE
az webapp create --name $APP_NAME --resource-group $GROUP_NAME --plan $APP_SERVICE_PLAN_NAME --deployment-local-git
az webapp  config set --python-version 3.4 --name $APP_NAME --resource-group $GROUP_NAME
az webapp deployment source config-local-git --name $APP_NAME --resource-group $GROUP_NAME --query url --output tsv
GIT_LOCATION=$(az webapp deployment source config-local-git --name $APP_NAME --resource-group $GROUP_NAME --query url --output tsv)
git remote add azure $GIT_LOCATION
git push azure master
