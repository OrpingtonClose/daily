#https://docs.microsoft.com/en-us/azure/app-service/containers/tutorial-nodejs-mongodb-app

sudo snap install mongo33
sudo systemctl start snap.mongo33.mongod.service
MONGO_PID=$(sudo systemctl show snap.mongo33.mongod.service | grep '^MainPID' | cut -d'=' -f2)
# lsof -a -> AND filter
# lsof -i -> network filter
# lsof -p -> filter by pid
MONGO_PORT=$(sudo lsof -aF -p $MONGO_PID -i -sTCP:LISTEN | grep '^n' | cut -d':' -f2)
export MONGODB_URI=mongodb://0.0.0.0:$MONGO_PORT
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p


git clone https://github.com/Azure-Samples/meanjs.git
cd meanjs
npm install
npm start

GROUP=$(openssl rand -base64 15 | tr -d -c A-Za-z)
DBNAME=$(openssl rand -base64 25 | tr -d -c A-Za-z | tr A-Z a-z)
az login
az group create --name $GROUP --location "West Europe" --debug
az cosmosdb create --name $DBNAME --resource-group $GROUP --kind MongoDB --debug
PRIMARY_KEY=$(az cosmosdb list-keys --name $DBNAME --resource-group $GROUP | jq -r '.primaryMasterKey')
COSMOS_URI=mongodb://$DBNAME:$PRIMARY_KEY@$DBNAME.documents.azure.com:10250

cat - > config/env/local-production.js <<EOF
module.exports = {
  db: {
    uri: '$COSMOS_URI/mean?ssl=true&sslverifycertificate=false'
  }
};
EOF

npm i -g gulp
gulp prod
NODE_ENV=production node server.js

DEPLOYMENT_USER=$(openssl rand -base64 20 | tr -d -c A-Za-z0-9)
DEPLOYMENT_PASSWORD=$(openssl rand -base64 20 | tr -d -c A-Za-z0-9)
APP_PLAN=$(openssl rand -base64 25 | tr -d -c A-Za-z)
APP=$(openssl rand -base64 25 | tr -d -c A-Za-z)

az webapp deployment user set --user $DEPLOYMENT_USER --password $DEPLOYMENT_PASSWORD

az appservice plan create --name $APP_PLAN --resource-group $GROUP --sku B1 --is-linux
#https://docs.microsoft.com/en-us/cli/azure/webapp/config?view=azure-cli-latest#az-webapp-config-set
#az webapp config set --name $APP --resource-group $GROUP --linux-fx-version "NODE|6.9"
#az webapp config set --name $APP --resource-group $GROUP --linux-fx-version "NODE|lts"
RES=$(az webapp create --resource-group $GROUP --plan $APP_PLAN --name $APP --runtime "NODE|6.9" --deployment-local-git --debug)
#az webapp config appsettings set --name $APP --resource-group $GROUP --runtime "NODE|6.9"


#git remote add azure $(echo $RES | jq -r '.deploymentLocalGitUrl')
#git remote remove azure
git remote add azure $(echo https://$DEPLOYMENT_USER:$DEPLOYMENT_PASSWORD@$(echo $RES | jq -r '.deploymentLocalGitUrl' | sed "s/^https\:\/\/$DEPLOYMENT_USER@//"))
#takes a LONG time
git push azure master

xdg-open https://$(az webapp show --name $APP --resource-group $GROUP | jq -r '.defaultHostName')