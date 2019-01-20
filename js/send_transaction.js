var sha256 = require("sha256");
var _ = require("lodash");
var Web3 = require("web3");
var deployAddress = "http://localhost:8001";

var web3 = new Web3();
var provider = new web3.providers.HttpProvider(deployAddress);
web3.setProvider(provider);
if (web3.isConnected()) {
    console.log("connected")
}

var from = web3.eth.accounts.reduce((biggest_account, new_account) => {
    if (biggest_account) {
        return new_account;
    }
    if (web3.eth.getBalance(new_account) > web3.eth.getBalance(biggest_account)) {
        return new_account;
    } else {
        return biggest_account;
    }
});

var to = _.without(web3.eth.accounts, from)[0];
var unlockPasswordless = _.partial(web3.personal.unlockAccount, _, '');
[from, to].forEach(unlockPasswordless);

var txnHash = web3.eth.sendTransaction({
    from, to, value: web3.toWei("1", "ether")
});

web3.eth.accounts.map(web3.eth.getBalance).map(balance => balance.toString(10));

var contractCode = "contract SimpleStorage {uint storedData;event Stored(uint x);function set(uint x) {storedData = x; Stored(x);} function get() constant returns (uint retVal) {return storedData;}}";
var solc = require("solc");
var contractCompiled = solc.compile(contractCode).contracts;

var {interface, bytecode} = contractCompiled[Object.keys(contractCompiled)[0]];
var abi = JSON.parse(interface);
var data = `0x${bytecode}`;
var simpleStore = web3.eth.contract(abi);

var deployed = simpleStore.new({from, data, gas:"4700000"});
var blockRange = {
    fromBlock: 0,
    toBlock: "latest"
};

var event = deployed.Stored(null, blockRange);
event.get(function(error, result) {
    if (error) {
        console.log("=========================ERROR:");
        console.log(error);
    } else {
        console.log(result);
    }
});
event.watch(function(error, result){
    if (!error) {
        console.log("WATCH RESULT");
        console.log(result.args.status);
    } else {
        console.log(error);
    }
});
var allEvents = deployed.allEvents(blockRange);
allEvents.watch(function(error, result){
    if (!error) {
        console.log("ALL WATCH RESULT");
        console.log(result.args.status);
    } else {
        console.log(error);
    }
});


var num = 423;
console.log(`will probably cost ${deployed.set.estimateGas(num)}`);
var txrec = deployed.set.sendTransaction(num, {from});
if (deployed.get.call().eq(num)) {
    console.log("success");
}


//0xaCdEc2eB40f44237822b7E9DAD501095164b771F

