var Web3 = require('web3');
var _ = require("lodash");

// if (typeof web3 === 'undefined') {
//     return;
// }

var urls = _.range(8000, 9000).map(n=>{
    let url = `http://localhost:${n}`;
    web3 = new Web3(new Web3.providers.HttpProvider(url));
    return web3.isConnected() ? web3.currentProvider.host : "";
});
var validUrl = _.compact(urls);

web3 = new Web3(new Web3.providers.HttpProvider(validUrl[0]));
try {
    console.log(web3.eth.getBlock(web3.eth.defaultBlock));
} catch(e) {
    console.log(e);
}

web3.eth.getBlock("pending", function(error, result) {
    if(!error) {
        console.log(result);
    } else {
        console.log(error);
    }
});
var address = web3.eth.accounts.pop();
var balance = web3.eth.getBalance(address);
console.log(balance.toString(10));

var block = web3.eth.getBlock("latest");
while (!block.transactions.length || block.number === 0) {
    block = web3.eth.getBlock(block.number - 1);
}

var tx = block.transactions.pop();
web3.eth.getTransactionReceipt(tx);
                                