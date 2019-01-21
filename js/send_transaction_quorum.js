var _ = require("lodash");
var Web3 = require("web3");

var abi = [{"constant":true,"inputs":[],"name":"storedData","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"x","type":"uint256"}],"name":"set","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"get","outputs":[{"name":"retVal","type":"uint256"}],"payable":false,"type":"function"},{"inputs":[{"name":"initVal","type":"uint256"}],"payable":false,"type":"constructor"}];
var data = "0x6060604052341561000f57600080fd5b604051602080610149833981016040528080519060200190919050505b806000819055505b505b610104806100456000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680632a1afcd914605157806360fe47b11460775780636d4ce63c146097575b600080fd5b3415605b57600080fd5b606160bd565b6040518082815260200191505060405180910390f35b3415608157600080fd5b6095600480803590602001909190505060c3565b005b341560a157600080fd5b60a760ce565b6040518082815260200191505060405180910390f35b60005481565b806000819055505b50565b6000805490505b905600a165627a7a72305820d5851baab720bba574474de3d09dbeaabc674a15f4dd93b974908476542c23f00029";
var gas = 0x47b760;

//var simpleContract = web3.eth.contract(abi);

var privateKeys = {"http://localhost:8001": "/Z1+Fe3tRAf+lyyXKZCil8pkSebWW+O0XELGRNquIlE=",
                   "http://localhost:8002": "3f/cPMz+tu1bPUXRgGjNVFbWQly45ix9s6STZYQ8Dh4=",
                   "http://localhost:8003": "rZpUaM5y4yk3qbAchczsFpSX+RmJHpLho8eAxf2h6Do=",
                   "http://localhost:8004": "WC0NbFD3f3bSOymsNTWYuCvIi3gWeOCU6DKqDpqBexU="};

var nodes = _.entries(privateKeys).map( entries =>{
    var key = entries[0];
    var value = entries[1];
    var web3 = new Web3();
    var provider = new web3.providers.HttpProvider(key);
    web3.setProvider(provider);
    return {
        host: key,
        port: parseInt(key.split(":").pop()),
        pubkey: value,
        web3
    };
});
                

var l = nodes.length;
var a = _.range(l);
var r = a.map(n=>[n]);

r = r.concat(_.flatten(a.map( m => {
    return a.map( n => {
        return _.orderBy([n, m]);
    });
})).filter(m => {
    return _.every(m.map(n=>{
        return _.without(m, n).length;
    }), n => n === m.length-1);
}));
r = r.concat(_.flatten(_.flatten(a.map( m => {
    return a.map( n => {
        return a.map( z => {
            return _.orderBy([n, m, z]);
        });
    });
}))).filter(m => {
    return _.every(m.map(n=>{
        return _.without(m, n).length;
    }), n => n === m.length-1);
}))
r.push(a);
r.unshift([]);
var nodeCombinations = r.map(r => _.at(nodes, r)); 

var wait = (contract, callback) => {
    if(!contract.address) {
        setTimeout(function () {
            wait(contract, callback);
        }, 1000);
    } else{
        callback();
    }
}

var value = 1000;
function DeployPublicAndCall() {
    nodes.forEach(nodeDeploying => {    
        nodeDeploying.web3.personal.unlockAccount(nodeDeploying.web3.eth.accounts[0]);
        value += 1;
        var localValue = value;
        var contractDeployed = nodeDeploying.web3.eth.contract(abi).new(localValue, {
            from: nodeDeploying.web3.eth.accounts[0], 
            data, 
            gas
        });

        wait(contractDeployed, ()=>{
            nodes.forEach(node=>{
                var result = node.web3.eth.contract(abi).at(contractDeployed.address).get.call();
                console.log(`public contract public call ${localValue === result.toNumber() ? "success" : "can't find"} -> ${nodeDeploying.host} -> ${node.host}`);
            });        
        });
    });
}

function DeployPrivateAndCall(nodesAddressed) {
    nodes.forEach(nodeDeploying => {    
        nodeDeploying.web3.personal.unlockAccount(nodeDeploying.web3.eth.accounts[0]);
        value += 1;
        var localValue = value;
        var contractDeployed = nodeDeploying.web3.eth.contract(abi).new(localValue, {
            from: nodeDeploying.web3.eth.accounts[0], 
            data, gas, privateFor: _.without(nodesAddressed.map(node=>node.pubkey), nodeDeploying.pubkey)
        });
        //console.log(`private contract with all nodes participating public call`);
        var nodesAddressedMessage = nodesAddressed.map(node=>node.port).join(",") || "none"; 
        wait(contractDeployed, ()=>{
            nodes.forEach(node=>{
                var result = node.web3.eth.contract(abi).at(contractDeployed.address).get.call().toNumber();
                var resultString = localValue === result ? "success" : "-------";
                console.log(`${nodesAddressedMessage} ${resultString} ${nodeDeploying.host} -> ${node.host}`);
            });        
        });
    });
}

DeployPublicAndCall();
var allNodes = _.flatten(_.filter(nodeCombinations, comb=>comb.length === nodes.length));
DeployPrivateAndCall(allNodes)
DeployPrivateAndCall([])

var c;
nodeCombinations.forEach(function(comb) {
    c = comb;
    console.log(comb);
//    DeployPrivateAndCall(comb);
});
DeployPrivateAndCall(c);


var deployAccount = nodes[0].web3.eth.accounts[0];
nodes[0].web3.personal.unlockAccount(deployAccount);

var initialValue = 42;
var contractDeployed = nodes[0].web3.eth.contract(abi).new(initialValue, {
    from: deployAccount, 
    data, 
    gas, 
    privateFor: [nodes[3].pubkey]
});

nodes.forEach(node=>{
    var result = node.web3.eth.contract(abi).at(contractDeployed.address).get.call();
    console.log(`${initialValue == result.toNumber()} -> ${node.host}`);
});

var value = 442;
var from = nodes[0].web3.eth.accounts[0];
nodes[0].web3.personal.unlockAccount(from);
nodes[0].web3.eth.contract(abi).at(contractDeployed.address).set.sendTransaction(value, { from, gas });

console.log(`initial "${value}": public transaction to private contract (node 1 + 4)`)
nodes.forEach(node=>{
    var from = node.web3.eth.accounts[0];
    var hostSetting = node.host;
    node.web3.personal.unlockAccount(from);
    value += 1;
    node.web3.eth.contract(abi).at(contractDeployed.address).set.sendTransaction(value, {from, gas});
    nodes.forEach(node=>{
        var result = node.web3.eth.contract(abi).at(contractDeployed.address).get.call();
        console.log(`${value} -> ${node.host} -> ${result.toString()}`);
    });
});

var value = 3441;
var from = nodes[0].web3.eth.accounts[0];
nodes[0].web3.personal.unlockAccount(from);
nodes[0].web3.eth.contract(abi).at(contractDeployed.address).set.sendTransaction(value, { from, gas });

console.log(`initial "${value}": private transaction (1 + 4) to private contract (node 1 + 4)`);
var privateFor = _.at(nodes, [0, 3]).map(node=>node.pubkey);
nodes.forEach(node=>{
    var from = node.web3.eth.accounts[0];
    var privateFor = _.without(privateFor, node.pubkey);
    var hostSetting = node.host;
    value += 1;
    node.web3.personal.unlockAccount(from);
    node.web3.eth.contract(abi).at(contractDeployed.address).set.sendTransaction(value, {from, gas, privateFor});
    nodes.forEach(node=>{
        var result = node.web3.eth.contract(abi).at(contractDeployed.address).get.call();
        console.log(`${value} -> ${hostSetting} -> ${node.host} -> ${result.toString()}`);
    });
});

var a = [0, 1, 2, 3];
var indices = a.map(n=>[n]);
indices.push(
    a.map(n=>[a.map(m=>[n,m])])
);




//var pubkeyCombinations = r.map(c=>_.at(nodes.map(n=>n.pubkey), c))

r.map(c=>_.at(nodes.map(n=>n.pubkey), c)).forEach(privateFor => {
    var value = _.random(10, 1000000);
    var from = nodes[0].web3.eth.accounts[0];
    nodes[0].web3.personal.unlockAccount(from);
    nodes[0].web3.eth.contract(abi).at(contractDeployed.address).set.sendTransaction(value, { from, gas });
    
    console.log(`initial "${value}": private transaction (1 + 4) to private contract (node 1 + 4)`);
    var privateFor = _.at(nodes, [0, 3]).map(node=>node.pubkey);
    nodes.forEach(node=>{
        var from = node.web3.eth.accounts[0];
        var privateFor = _.without(privateFor, node.pubkey);
        var hostSetting = node.host;
        value += 1;
        node.web3.personal.unlockAccount(from);
        node.web3.eth.contract(abi).at(contractDeployed.address).set.sendTransaction(value, {from, gas, privateFor});
        nodes.forEach(node=>{
            var result = node.web3.eth.contract(abi).at(contractDeployed.address).get.call();
            console.log(`${value} -> ${hostSetting} -> ${node.host} -> ${result.toString()}`);
        });
    });
});



nodes[0].web3.eth.contract(abi).at(contractDeployed.address).get.call()
nodes[1].web3.eth.contract(abi).at(contractDeployed.address).get.call()
nodes[2].web3.eth.contract(abi).at(contractDeployed.address).get.call()
nodes[3].web3.eth.contract(abi).at(contractDeployed.address).get.call()





var rpcEndpoint = "http://localhost:8001";
var web3 = new Web3();
var provider = new web3.providers.HttpProvider(rpcEndpoint);
web3.setProvider(provider);
//var quorumjs = require("quorum-js");
var from = web3.eth.accounts[0]
web3.eth.defaultAccount = from;


var privateFor = [_.values(_.omit(privateKeys, rpcEndpoint))[0]];  


var simpleContract = web3.eth.contract(abi);
web3.personal.unlockAccount(from);
// var simple = simpleContract.new(42, opts, function(e, contract) {
//     //console.log(contract);
//     // if (e) {
//     //     reject(e);
//     // } else {
//     //     resolve(contract);
//     // }
// });

new Promise(function (resolve, reject) {
    simpleContract.new(42, opts, function(e, contract) {
        //console.log(contract);
        // if (e) {
        //     reject(e);
        // } else {
        //     resolve(contract);
        // }
    });
}).then(data=>{
    console.log("===================");
    console.log(data);
    // if (data.address) {
    //     return data.address;
    // } else {
    //     filter = web3.eth.filter("latest");
        //return new Promise(function(resolve, reject) {
        //    resolve("something");
            // console.log("=======================");
            // filter.watch(function(error, result) {
            //     console.log("=======================");
            //     if (error) {
            //         reject(error);
            //     }
            //     var tx = web3.eth.getTransactionReceipt(data.transactionHash);
            //     if (tx && tx.contractAddress) {
            //         resolve(tx.contractAddress);
            //         filter.stopWatching();
            //     }
            // });
        //});
//    }
}).catch(err=>{
    console.log(err);
}).then(address =>{
    console.log(`address: ${address}`);
});

// transactionHash
// address
// if (!contract.address) {
//     console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");
// } else {
//     console.log("Contract mined! Address: " + contract.address);
//     console.log(contract);
// }



a = web3.eth.accounts[0]
web3.eth.defaultAccount = a;

// abi and bytecode generated from simplestorage.sol:
// > solcjs --bin --abi simplestorage.sol
var abi = [{"constant":true,"inputs":[],"name":"storedData","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"x","type":"uint256"}],"name":"set","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"get","outputs":[{"name":"retVal","type":"uint256"}],"payable":false,"type":"function"},{"inputs":[{"name":"initVal","type":"uint256"}],"payable":false,"type":"constructor"}];

var bytecode = "0x6060604052341561000f57600080fd5b604051602080610149833981016040528080519060200190919050505b806000819055505b505b610104806100456000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680632a1afcd914605157806360fe47b11460775780636d4ce63c146097575b600080fd5b3415605b57600080fd5b606160bd565b6040518082815260200191505060405180910390f35b3415608157600080fd5b6095600480803590602001909190505060c3565b005b341560a157600080fd5b60a760ce565b6040518082815260200191505060405180910390f35b60005481565b806000819055505b50565b6000805490505b905600a165627a7a72305820d5851baab720bba574474de3d09dbeaabc674a15f4dd93b974908476542c23f00029";

var simpleContract = web3.eth.contract(abi);
//_.entries(_.omit(privateKeys, rpcEndpoint)).forEach( pair => {
[_.entries(privateKeys)[1]].forEach( pair => {
    web3.personal.unlockAccount(web3.eth.accounts[0]);
    var host = pair[0];
    var pubkey = pair[1];
    var simple = simpleContract.new(42, {from:web3.eth.accounts[0]
                                        ,data: bytecode
                                        ,gas: 0x47b760
                                        ,privateFor: [pubkey]}
                                        ,function(e, contract) {
        console.log("==================================" + host);
        console.log("==================================" + pubkey);
        if (e) {
            console.log("err creating contract", e);
        } else {
            // if (!contract.address) {
            //     console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");
            // } else {
            //     console.log("Contract mined! Address: " + contract.address);
                console.log("=================================");
                console.log(simple.get.call({from:web3.eth.accounts[0]}));
            // }
        }
    });
});

var host = h;
console.log(h);
    // web3.personal.unlockAccount(web3.eth.accounts[0]);
    // var simple = simpleContract.new(42, {from:web3.eth.accounts[0]
    //                                     ,data: bytecode
    //                                     ,gas: 0x47b760
    //                                     ,privateFor: [privateKeys[host]]}
    //                                     ,function(e, contract) {
    //     console.log("==================================" + host);
    //     console.log("==================================" + privateKeys[host]);
    //     // if (e) {
    //     //     console.log("err creating contract", e);
    //     // } else {
    //     //     if (!contract.address) {
    //     //         console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");
    //     //     } else {
    //     //         console.log("Contract mined! Address: " + contract.address);
    //     //         console.log(contract);
    //     //     }
    //     // }
    // });
}

privateKeys.forEach(key => {
    web3.personal.unlockAccount(a);
    var simple = simpleContract.new(42, {from:web3.eth.accounts[0], data: bytecode, gas: 0x47b760, privateFor: [key]}, function(e, contract) {
        console.log("==================================" + key);
        if (e) {
            console.log("err creating contract", e);
        } else {
            if (!contract.address) {
                console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");
            } else {
                console.log("Contract mined! Address: " + contract.address);
                console.log(contract);
            }
        }
    });
});

//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

a = web3.eth.accounts[0]
web3.eth.defaultAccount = a;

// abi and bytecode generated from simplestorage.sol:
// > solcjs --bin --abi simplestorage.sol
var abi = [{"constant":true,"inputs":[],"name":"storedData","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"x","type":"uint256"}],"name":"set","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"get","outputs":[{"name":"retVal","type":"uint256"}],"payable":false,"type":"function"},{"inputs":[{"name":"initVal","type":"uint256"}],"payable":false,"type":"constructor"}];

var bytecode = "0x6060604052341561000f57600080fd5b604051602080610149833981016040528080519060200190919050505b806000819055505b505b610104806100456000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680632a1afcd914605157806360fe47b11460775780636d4ce63c146097575b600080fd5b3415605b57600080fd5b606160bd565b6040518082815260200191505060405180910390f35b3415608157600080fd5b6095600480803590602001909190505060c3565b005b341560a157600080fd5b60a760ce565b6040518082815260200191505060405180910390f35b60005481565b806000819055505b50565b6000805490505b905600a165627a7a72305820d5851baab720bba574474de3d09dbeaabc674a15f4dd93b974908476542c23f00029";

var filter = web3.eth.filter('latest');
filter.watch(console.log);
//function(error, result){
//    console.log("=================");
    // console.log(JSON.stringify(result));
    // console.log(JSON.stringify(result).replace(/^/gm, "new block mined: "));
    // filter.stopWatching();
//});
filter.stopWatching();


var simpleContract = web3.eth.contract(abi);
var opts = {
    from:web3.eth.accounts[0], 
    data: bytecode, 
    gas: 0x47b760, 
    privateFor: ["rZpUaM5y4yk3qbAchczsFpSX+RmJHpLho8eAxf2h6Do="]
};

var a = 0;
var checkTx = function() {
    //var address = web3.eth.getTransactionReceipt(tx).contractAddress;
    a += 1;
    //if (address) {
    if (a > 3) {
        console.log("returning");
        return a;
        //return address         
    } else {
        console.log("debouncing");
        var d = _.debounce(checkTx, 1000)();
        console.log(d); 
        return d;
    }
}
//old transaction private => '0xabab2e6cf56da7a9dc4ff9b5625ea6ac2ea2f80d1194b20f6a42e74e160c0180'

var async = require("async")

task(callback(err, result), results)

var a = 0;
var f = (callback, result) => {
    a += 1;
    console.log(a);
    if ( a > 3 ) {
        callback(null, a);
    } else {
        callback("yes");
    }
}


var apiMethod = () => {
    console.log(a);
    ++a;
}
async.until(() => a > 3, apiMethod)

var a = 0;
var f = () => {
    if(a<5) {
        setTimeout(function () {
            a += 1;
            console.log(a);
            f();
        }, 1000);
    }
}
f();

var count = 0;

async.whilst(
    function () { return count < 5; },
    function (callback) {
        console.log(count)
        count++;
        setTimeout(function () {
            callback(null, count);
        }, 1000);
    },
    function (err, n) {
        console.log(err, n)
        // 5 seconds have passed, n = 5
    }
);

console.log("herp")

async.retry({times: 5, interval: 2000}, function(callback, result) {
    apiMethod();
    console.log(`result ${[...arguments]}`);
    if ( a > 3 ) {
        callback("no", a);
    } else {
        callback("yes");
    }
    return a;
});

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
var Web3 = require("web3");
var privateKeys = {"http://localhost:8001": "/Z1+Fe3tRAf+lyyXKZCil8pkSebWW+O0XELGRNquIlE=",
                   "http://localhost:8002": "3f/cPMz+tu1bPUXRgGjNVFbWQly45ix9s6STZYQ8Dh4=",
                   "http://localhost:8003": "rZpUaM5y4yk3qbAchczsFpSX+RmJHpLho8eAxf2h6Do=",
                   "http://localhost:8004": "WC0NbFD3f3bSOymsNTWYuCvIi3gWeOCU6DKqDpqBexU="};

var _ = require("lodash");
var rpcEndpoint = "http://localhost:8001";
var web3 = new Web3();
var provider = new web3.providers.HttpProvider(rpcEndpoint);
web3.setProvider(provider);
//var quorumjs = require("quorum-js");
var from = web3.eth.accounts[0]

var abi = [{"constant":true,"inputs":[],"name":"storedData","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"x","type":"uint256"}],"name":"set","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"get","outputs":[{"name":"retVal","type":"uint256"}],"payable":false,"type":"function"},{"inputs":[{"name":"initVal","type":"uint256"}],"payable":false,"type":"constructor"}];
var bytecode = "0x6060604052341561000f57600080fd5b604051602080610149833981016040528080519060200190919050505b806000819055505b505b610104806100456000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680632a1afcd914605157806360fe47b11460775780636d4ce63c146097575b600080fd5b3415605b57600080fd5b606160bd565b6040518082815260200191505060405180910390f35b3415608157600080fd5b6095600480803590602001909190505060c3565b005b341560a157600080fd5b60a760ce565b6040518082815260200191505060405180910390f35b60005481565b806000819055505b50565b6000805490505b905600a165627a7a72305820d5851baab720bba574474de3d09dbeaabc674a15f4dd93b974908476542c23f00029";


var simpleContract = web3.eth.contract(abi);

var opts = {
    from:web3.eth.accounts[0], 
    data: bytecode, 
    gas: 0x47b760, 
    privateFor: ["rZpUaM5y4yk3qbAchczsFpSX+RmJHpLho8eAxf2h6Do="]
};

//var opts = _.omit(opts, "privateFor");

_.entries(privateKeys).forEach(pair=>{

    var web3 = new Web3();
    var provider = new web3.providers.HttpProvider(pair[0]);
    web3.setProvider(provider);
    web3.personal.unlockAccount(web3.eth.accounts[0]);
    //var contract = simpleContract.at(address);
    var numberToStore = 10000 + parseInt(pair[0].split(":").pop());
    //var newOpts = _.set(opts, "privateFor", _.values(_.omit(privateKeys, pair[1])));
    //var newOpts = _.set(opts, "privateFor", [pair[1]]);
    var opts = {
        from: web3.eth.accounts[0], 
        gas: 0x47b760, 
        privateFor: ["rZpUaM5y4yk3qbAchczsFpSX+RmJHpLho8eAxf2h6Do="]
    };
    
    var newOpts = opts;

    var simple;
    var address;
    try {
        simple = simpleContract.new(numberToStore, newOpts)
        address = web3.eth.getTransactionReceipt(simple.transactionHash).contractAddress;
    } catch {
        console.log("dind't work");    
        return;
    }
    console.log(`new ${numberToStore} {"${pair[0]}": "${pair[1]}"}`);

    _.entries(privateKeys).forEach(pair=>{
        var hostSetting = pair[0];
        var pubkeySetting = pair[1];
        
        var web3 = new Web3();
        var provider = new web3.providers.HttpProvider(hostSetting);
        web3.setProvider(provider);
        web3.personal.unlockAccount(web3.eth.accounts[0]);
        var contract = simpleContract.at(address);
        var numberToStore = parseInt(hostSetting.split(":").pop());
        var newOpts = _.set(opts, "privateFor", [pubkeySetting]);
        try {
            contract.set.sendTransaction(numberToStore, newOpts);
            console.log(`  set ${numberToStore} {"${hostSetting}": "${pubkeySetting}"}`);
        } catch {
            console.log(` cant set {"${hostSetting}": "${pubkeySetting}"}`);
        }    
        _.entries(privateKeys).forEach(pair=>{
            var web3 = new Web3();
            var provider = new web3.providers.HttpProvider(pair[0]);
            web3.setProvider(provider);
            web3.personal.unlockAccount(web3.eth.accounts[0]);
            var contract = simpleContract.at(address);
            var newOpts;
            if (pair[1] === pubkeySetting) {
                newOpts = _.set(opts, "privateFor", [pair[1]]);
            } else {
                newOpts = _.omit(opts, "privateFor");
            }
            try {
                var result = contract.get.call(_.set(opts, "privateFor", pair[1])).toString();
                console.log(`    ${result} <-- {"${pair[0]}": "${pair[1]}"}`);
            } catch {
                console.log(`    didn't work <-- {"${pair[0]}": "${pair[1]}"}`);
            }    
        });   
    });
});

//simple.transactionHash
await async.retry({times: 30, interval: 2000}, (callback, result) =>{
    web3.eth.getTransactionReceipt(c.transactionHash);

}, function(err, result) {
    console.log(result);
});




web3.personal.unlockAccount(web3.eth.accounts[0]);
var simple = simpleContract.new(42, opts)
Object.keys(simple);
simple.transactionHash

, function(e, contract) {
	if (e) {
		console.log("err creating contract", e);
	} else {
		if (!contract.address) {
            var get = simpleContract.at(web3.eth.getTransactionReceipt(contract.transactionHash).contractAddress).get.call().toString();
            console.log(get);
            //console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");
            //console.log(Object.keys(contract));
		} else {
			console.log("Contract mined! Address: " + contract.address);
			console.log(contract);
		}
	}
});

