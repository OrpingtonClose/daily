//sudo npm install azure
//https://github.com/Azure/azure-sdk-for-node/blob/master/Documentation/Authentication.md
//https://github.com/Azure/azure-sdk-for-node
//https://github.com/Azure/azure-sdk-for-node/blob/master/examples/ARM/compute/vm-sample.js#L98
const Azure = require('azure');
const MsRest = require('ms-rest-azure');

let creds;
let subscriptionId;
MsRest.interactiveLogin((err, credentials, subscriptions) => {
    //found the third parameter with subscriptions here:
    //https://www.npmjs.com/package/azure-graph
    subscriptionId = subscriptions[1].id;
    creds = credentials;
});

const printKeys = obj => console.log(Object.keys(obj).map(key=>`${key} => ${obj[key]}`).join('\n'));
printKeys(creds)

//https://azure.microsoft.com/en-gb/resources/samples/resource-manager-node-resources-and-groups/

let resources = Azure.createResourceManagementClient(creds, subscriptionId);
Object.keys(resources)
printKeys(resources)
var location = 'westus';
var tags = { delete: 'me' };

resources.resourceGroups.createOrUpdate("createdUsingNodeSdk", { location, tags }, (err, res) =>{
    if (err) {  
        console.log("err=============");
        console.log(err);
    } else {
        console.log("res=============");
        console.log(res);
    }
});
//FAILURE
// The access token is from the wrong issuer \'https://sts.windows.net/.../\'. 
// It must match the tenant \'https://sts.windows.net/.../\' associated with this subscription. 
// Please use the authority (URL) \'https://login.windows.net/...\' to get the token. 
// Note, if the subscription istransferred to another tenant there is no impact to the services, but information about 
// new tenant could take time to propagate (up to an hour). If you just transferred your subscription and see this error message, 
// please try back later.

//const vms = Azure.createComputeManagementClient(creds, '24f7d5e9-679f-4351-9553-bbc5240da83c');

