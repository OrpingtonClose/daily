var Web3 = require("web3");
var deployAddress = "http://localhost:7545";

var web3 = new Web3();
var provider = new web3.providers.HttpProvider(deployAddress);
web3.setProvider(provider);
if (web3.isConnected()) {
    console.log("connected")
}