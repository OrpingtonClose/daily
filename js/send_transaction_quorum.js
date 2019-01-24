var _ = require("lodash");
var Web3 = require("web3");

var abi = [{"constant":true,"inputs":[],"name":"storedData","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"x","type":"uint256"}],"name":"set","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"get","outputs":[{"name":"retVal","type":"uint256"}],"payable":false,"type":"function"},{"inputs":[{"name":"initVal","type":"uint256"}],"payable":false,"type":"constructor"}];
var data = "0x6060604052341561000f57600080fd5b604051602080610149833981016040528080519060200190919050505b806000819055505b505b610104806100456000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680632a1afcd914605157806360fe47b11460775780636d4ce63c146097575b600080fd5b3415605b57600080fd5b606160bd565b6040518082815260200191505060405180910390f35b3415608157600080fd5b6095600480803590602001909190505060c3565b005b341560a157600080fd5b60a760ce565b6040518082815260200191505060405180910390f35b60005481565b806000819055505b50565b6000805490505b905600a165627a7a72305820d5851baab720bba574474de3d09dbeaabc674a15f4dd93b974908476542c23f00029";
var gas = 0x47b760;

var waitAndCall = (condition, callThis) => {
    if(!condition()) {
        setTimeout(function () {
            waitAndCall(condition, callThis);
        }, 1000);
    } else{
        callThis();
    }
}
var waitForDeployment = (contract, callback) => waitAndCall(() => contract.address, callback)
var waitForTx = (web3, txReceiptHash, callback) => waitAndCall(() => web3.eth.getTransactionReceipt(txReceiptHash), callback)
//var waitForDeployment = (contract, callback) => waitAndCall(() => contract.address, callback)

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
       

//simple, but works!
function simplestSet() {
    var nodeDeploying = nodes[0];
    var nodeSetting = nodes[1];
    var nodeGetting = nodes[2];
    var simpleContract = nodeDeploying.web3.eth.contract(abi);

    nodeDeploying.web3.personal.unlockAccount(nodeDeploying.web3.eth.accounts[0]);
    var numberToDeploy = 123455;

    var opts = {
        from: nodeDeploying.web3.eth.accounts[0], 
        gas: 0x47b760, 
        privateFor: _.without(nodes.map(node=>node.pubkey), nodeDeploying.pubkey),
        data
    };

    var simple = simpleContract.new(numberToDeploy, opts);
    var address;

    waitForDeployment(simple, () => {
        console.log("done");
        var simpleContract = nodeSetting.web3.eth.contract(abi).at(simple.address);
        var numberToSet = 33333333;
        var newOpts = _.set(opts, "privateFor", _.without(nodes.map(node=>node.pubkey), nodeSetting.pubkey));

        nodeSetting.web3.personal.unlockAccount(nodeSetting.web3.eth.accounts[0]);
        var tx = simpleContract.set.sendTransaction(numberToSet, {
            from: nodeSetting.web3.eth.accounts[0], 
            gas: 0x47b760, 
            privateFor: _.without(nodes.map(node=>node.pubkey), nodeSetting.pubkey)
        });
        waitForTx(nodeSetting.web3, tx, () => {
            var simpleContract = nodeGetting.web3.eth.contract(abi).at(simple.address);
            console.log(numberToSet);
            console.log(simpleContract.get.call().toString());
        });
    });
}

function simpleSet(nodeDeploying, privateForDeploying, nodeSetting, privateForSetting, nodeGetting) {
    //var nodeDeploying = nodes[0];
    // var nodeSetting = nodes[1];
    // var nodeGetting = nodes[2];
    return new Promise((resolve, reject)=>{
        var simpleContract = nodeDeploying.web3.eth.contract(abi);

        nodeDeploying.web3.personal.unlockAccount(nodeDeploying.web3.eth.accounts[0]);
        var numberToDeploy = 123455;

        var simple = simpleContract.new(numberToDeploy, {
            from: nodeDeploying.web3.eth.accounts[0], 
            gas: 0x47b760, 
            privateFor: _.without(privateForDeploying.map(node=>node.pubkey), nodeDeploying.pubkey),
            data
        });

        waitForDeployment(simple, () => {
            console.log("done");
            var simpleContract = nodeSetting.web3.eth.contract(abi).at(simple.address);
            var numberToSet = 33333333;

            nodeSetting.web3.personal.unlockAccount(nodeSetting.web3.eth.accounts[0]);
            var tx = simpleContract.set.sendTransaction(numberToSet, {
                from: nodeSetting.web3.eth.accounts[0], 
                gas: 0x47b760, 
                privateFor: _.without(privateForSetting.map(node=>node.pubkey), nodeSetting.pubkey)
            });
            waitForTx(nodeSetting.web3, tx, () => {
                var simpleContract = nodeGetting.web3.eth.contract(abi).at(simple.address);
                resolve({
                    nodeDeploying, 
                    privateForDeploying, 
                    nodeSetting, 
                    privateForSetting, 
                    nodeGetting,
                    valueDeployedFits: simpleContract.get.call().toNumber() === numberToDeploy,
                    valueSetFits: simpleContract.get.call().toNumber() === numberToSet
                });
            });
        });
    });
}




// simpleSet(nodes[0], nodes, nodes[1], nodes, nodes[2]).then(data=>{
//     console.log(data);
// })

// //timeout
// nodes.forEach(node=>{
//     simpleSet(node, nodes, nodes[1], nodes, nodes[2]).then(data=>{
//         console.log(`${valueSetFits}`)
//     });
// });


// Promise.all(nodes.map(node=>{
//     return simpleSet(node, nodes, nodes[1], nodes, nodes[2]).then(data=>{
//         console.log(`${valueSetFits}`)
//     })
// })).then(data=>{
//     console.log("finished");
// })



function simpleDocumentHash(nodeDeploying, privateForDeploying, nodeSetting, privateForSetting, nodeGetting) {
    var data = '0x6060604052341561000f57600080fd5b6107378061001e6000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063693ec85e14610048578063e942b5161461012557600080fd5b341561005357600080fd5b6100a3600480803590602001908201803590602001908080601f016020809104026020016040519081016040528093929190818152602001838380828437820191505050505050919050506101c5565b6040518083815260200180602001828103825283818151815260200191508051906020019080838360005b838110156100e95780820151818401526020810190506100ce565b50505050905090810190601f1680156101165780820380516001836020036101000a031916815260200191505b50935050505060405180910390f35b341561013057600080fd5b6101c3600480803590602001908201803590602001908080601f0160208091040260200160405190810160405280939291908181526020018383808284378201915050505050509190803590602001908201803590602001908080601f016020809104026020016040519081016040528093929190818152602001838380828437820191505050505050919050506102ec565b005b60006101cf610652565b600080846040518082805190602001908083835b60208310151561020857805182526020820191506020810190506020830392506101e3565b6001836020036101000a03801982511681845116808217855250505050505090500191505090815260200160405180910390209050806000015481600101808054600181600116156101000203166002900480601f0160208091040260200160405190810160405280929190818152602001828054600181600116156101000203166002900480156102db5780601f106102b0576101008083540402835291602001916102db565b820191906000526020600020905b8154815290600101906020018083116102be57829003601f168201915b505050505090509250925050915091565b600080826040518082805190602001908083835b6020831015156103255780518252602082019150602081019050602083039250610300565b6001836020036101000a038019825116818451168082178552505050505050905001915050908152602001604051809103902060000154141561052f576040805190810160405280428152602001838152506000826040518082805190602001908083835b6020831015156103af578051825260208201915060208101905060208303925061038a565b6001836020036101000a0380198251168184511680821785525050505050509050019150509081526020016040518091039020600082015181600001556020820151816001019080519060200190610408929190610666565b509050507f0d3bbc3c02da6ed436712ca1a0f626f1269df703a105f034e4637c7b10fb7ba5600142848460405180851515151581526020018481526020018060200180602001838103835285818151815260200191508051906020019080838360005b8381101561048657808201518184015260208101905061046b565b50505050905090810190601f1680156104b35780820380516001836020036101000a031916815260200191505b50838103825284818151815260200191508051906020019080838360005b838110156104ec5780820151818401526020810190506104d1565b50505050905090810190601f1680156105195780820380516001836020036101000a031916815260200191505b50965050505050505060405180910390a161064e565b7f0d3bbc3c02da6ed436712ca1a0f626f1269df703a105f034e4637c7b10fb7ba5600042848460405180851515151581526020018481526020018060200180602001838103835285818151815260200191508051906020019080838360005b838110156105a957808201518184015260208101905061058e565b50505050905090810190601f1680156105d65780820380516001836020036101000a031916815260200191505b50838103825284818151815260200191508051906020019080838360005b8381101561060f5780820151818401526020810190506105f4565b50505050905090810190601f16801561063c5780820380516001836020036101000a031916815260200191505b50965050505050505060405180910390a15b5050565b602060405190810160405280600081525090565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f106106a757805160ff19168380011785556106d5565b828001600101855582156106d5579182015b828111156106d45782518255916020019190600101906106b9565b5b5090506106e291906106e6565b5090565b61070891905b808211156107045760008160009055506001016106ec565b5090565b905600a165627a7a723058207176027723d240e9ad1b72b1097da01fd495487de683c87031bbe742915a73140029';
    var abi = [{"constant":false,"inputs":[{"name":"fileHash","type":"string"}],"name":"get","outputs":[{"name":"timestamp","type":"uint256"},{"name":"owner","type":"string"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"owner","type":"string"},{"name":"fileHash","type":"string"}],"name":"set","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"anonymous":false,"inputs":[{"indexed":false,"name":"status","type":"bool"},{"indexed":false,"name":"timestamp","type":"uint256"},{"indexed":false,"name":"owner","type":"string"},{"indexed":false,"name":"fileHash","type":"string"}],"name":"logFileAddedStatus","type":"event"}];

    var simpleContract = nodeDeploying.web3.eth.contract(abi);

    nodeDeploying.web3.personal.unlockAccount(nodeDeploying.web3.eth.accounts[0]);
    var owner = "adasds";
    var hash = "6768033e216468247bd031a0a2d9876d79818f8f";
    
    var opts = {
        from: nodeDeploying.web3.eth.accounts[0], 
        gas: 0x47b760, 
        privateFor: _.without(privateForDeploying.map(node=>node.pubkey), nodeDeploying.pubkey),
        data
    };

    var simple = simpleContract.new(opts);

    waitForDeployment(simple, () => {
        console.log("done");
        var simpleContract = nodeSetting.web3.eth.contract(abi).at(simple.address);
        nodeSetting.web3.personal.unlockAccount(nodeSetting.web3.eth.accounts[0]);
        var tx = simpleContract.set.sendTransaction(owner, hash, {
            from: nodeSetting.web3.eth.accounts[0], 
            gas: 0x47b760, 
            privateFor: _.without(privateForSetting.map(node=>node.pubkey), nodeSetting.pubkey)
        });
        waitForTx(nodeSetting.web3, tx, () => {
            var simpleContract = nodeGetting.web3.eth.contract(abi).at(simple.address);
            var result = simpleContract.get.call(hash);
            console.log(result);
        });
    });
}
simpleDocumentHash(nodes[0], nodes, nodes[1], nodes, nodes[2])
//simplestDocumentHash();
// var nodeDeploying = nodes[0];
// var nodeSetting = nodes[1];
// var nodeGetting = nodes[2]; 
// var privateForDeploying = nodes;
// var privateForSetting = nodes;


// try {
//     simple = simpleContract.new(numberToStore, newOpts)
//     address = web3.eth.getTransactionReceipt(simple.transactionHash).contractAddress;
// } catch {
//     console.log("dind't work");    
//     return;
// }
// console.log(`new ${numberToStore} {"${pair[0]}": "${pair[1]}"}`);

//     _.entries(privateKeys).forEach(pair=>{
//         var hostSetting = pair[0];
//         var pubkeySetting = pair[1];
        
//         var web3 = new Web3();
//         var provider = new web3.providers.HttpProvider(hostSetting);
//         web3.setProvider(provider);
//         web3.personal.unlockAccount(web3.eth.accounts[0]);
//         var contract = simpleContract.at(address);
//         var numberToStore = parseInt(hostSetting.split(":").pop());
//         var newOpts = _.set(opts, "privateFor", [pubkeySetting]);
//         try {
//             contract.set.sendTransaction(numberToStore, newOpts);
//             console.log(`  set ${numberToStore} {"${hostSetting}": "${pubkeySetting}"}`);
//         } catch {
//             console.log(` cant set {"${hostSetting}": "${pubkeySetting}"}`);
//         }    
//         _.entries(privateKeys).forEach(pair=>{
//             var web3 = new Web3();
//             var provider = new web3.providers.HttpProvider(pair[0]);
//             web3.setProvider(provider);
//             web3.personal.unlockAccount(web3.eth.accounts[0]);
//             var contract = simpleContract.at(address);
//             var newOpts;
//             if (pair[1] === pubkeySetting) {
//                 newOpts = _.set(opts, "privateFor", [pair[1]]);
//             } else {
//                 newOpts = _.omit(opts, "privateFor");
//             }
//             try {
//                 var result = contract.get.call(_.set(opts, "privateFor", pair[1])).toString();
//                 console.log(`    ${result} <-- {"${pair[0]}": "${pair[1]}"}`);
//             } catch {
//                 console.log(`    didn't work <-- {"${pair[0]}": "${pair[1]}"}`);
//             }    
//         });   
//     });
// });




// function attemptThoroughTest() {
//     var l = nodes.length;
//     var a = _.range(l);
//     var r = a.map(n=>[n]);

//     r = r.concat(_.flatten(a.map( m => {
//         return a.map( n => {
//             return _.orderBy([n, m]);
//         });
//     })).filter(m => {
//         return _.every(m.map(n=>{
//             return _.without(m, n).length;
//         }), n => n === m.length-1);
//     }));
//     r = r.concat(_.flatten(_.flatten(a.map( m => {
//         return a.map( n => {
//             return a.map( z => {
//                 return _.orderBy([n, m, z]);
//             });
//         });
//     }))).filter(m => {
//         return _.every(m.map(n=>{
//             return _.without(m, n).length;
//         }), n => n === m.length-1);
//     }))
//     r.push(a);
//     r.unshift([]);
//     var nodeCombinations = r.map(r => _.at(nodes, r)); 

//     var wait = (contract, callback) => {
//         if(!contract.address) {
//             setTimeout(function () {
//                 wait(contract, callback);
//             }, 1000);
//         } else{
//             callback();
//         }
//     }

//     var abi = [{"constant":true,"inputs":[],"name":"storedData","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"x","type":"uint256"}],"name":"set","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"get","outputs":[{"name":"retVal","type":"uint256"}],"payable":false,"type":"function"},{"inputs":[{"name":"initVal","type":"uint256"}],"payable":false,"type":"constructor"}];
//     var data = "0x6060604052341561000f57600080fd5b604051602080610149833981016040528080519060200190919050505b806000819055505b505b610104806100456000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680632a1afcd914605157806360fe47b11460775780636d4ce63c146097575b600080fd5b3415605b57600080fd5b606160bd565b6040518082815260200191505060405180910390f35b3415608157600080fd5b6095600480803590602001909190505060c3565b005b341560a157600080fd5b60a760ce565b6040518082815260200191505060405180910390f35b60005481565b806000819055505b50565b6000805490505b905600a165627a7a72305820d5851baab720bba574474de3d09dbeaabc674a15f4dd93b974908476542c23f00029";
//     var gas = 0x47b760;

//     var deployContract = _.partial(function(bytecode, abi, gas, initialValue, nodeDeploying, nodesPrivateFor) {
//         return new Promise(function(resolve, reject) {
//             nodeDeploying.web3.personal.unlockAccount(nodeDeploying.web3.eth.accounts[0]);
//             var opts = {};
//             opts.from = nodeDeploying.web3.eth.accounts[0];
//             opts.data = bytecode;
//             opts.gas = gas;
//             if (nodesPrivateFor !== undefined) {
//                 opts.privateFor = _.without(nodesPrivateFor.map(node=>node.pubkey), nodeDeploying.pubkey);
//             }
//             var contractDeployed = nodeDeploying.web3.eth.contract(abi).new(initialValue, opts)
//             var result = {initialValue, contractDeployed, nodeDeploying, deployedPrivateFor: nodesPrivateFor};
//             waitForDeployment(contractDeployed, function() {
//                 resolve(result);
//             });
//         });
//     }, data, abi, gas, 42); 

//     var getAndCheck = function(contractDeployed, 
//                             deployedValue, nodeDeploying, deployedPrivateFor, 
//                             settingValue, nodeSetting, settingPrivateFor, 
//                             nodeGetting) {
//         return new Promise((resolve, reject) => {
//             var resultReturnedFromContract = nodeGetting.web3.eth.contract(contractDeployed.abi).at(contractDeployed.address).get.call();
//             var valueSameAsDeployed = deployedValue === resultReturnedFromContract.toNumber();
//             var success;
//             if (settingValue) {
//                 var valueSameAsSetting = settingValue === resultReturnedFromContract.toNumber();
//                 success = valueSameAsSetting;
//             } else {
//                 success = valueSameAsDeployed;
//             }
//             resolve({valueSameAsDeployed, valueSameAsSetting, success, 
//                     nodeDeploying, deployedPrivateFor, 
//                     nodeSetting, settingPrivateFor, nodeGetting});
//         });
//     }

//     var saveResult = function(args) {
//         var {valueSameAsDeployed, valueSameAsSetting, success,
//             nodeDeploying, deployedPrivateFor, 
//             nodeSetting, settingPrivateFor, nodeGetting} = args;
//         return new Promise(function(resolve, reject) {
//             var result = _.omitBy({ valueSameAsDeployed, valueSameAsSetting, success }, _.negate(_.identity));
//             result[`deployed:${nodeDeploying.port}`] = true;
//             if (deployedPrivateFor) {
//                 deployedPrivateFor.forEach( node => {
//                     result[`deployed_private_for:${node.port}`] = true;    
//                 });
//             }
//             if (nodeSetting) {
//                 result[`setting:${nodeSetting.port}`] = true;
//                 settingPrivateFor.forEach( node => {
//                     result[`deployed_private_for:${node.port}`] = true;    
//                 }); 
//             }
//             result[`getter:${nodeGetting.port}`] = true;
//             resolve(result);
//         });
//     }

// // var saveToLeveldb = function(path) {
// //     const levelup = require('levelup');
// //     const sqldown = require('sqldown');
// //     const SQLite = require('sqlite3');
// //     const uuid = require('uuid/v1');
// //     const sqlite = new SQLite.Database(path);
// //     return function(args) {
// //         var {valueSameAsDeployed, valueSameAsSetting, success,
// //             nodeDeploying, deployedPrivateFor, 
// //             nodeSetting, settingPrivateFor, nodeGetting} = args;
// //         return new Promise(function(resolve, reject) {
                        
// //             var db = levelup(sqldown(path));
// //             var key = uuid();
// //             var put = (field, value) =>{
// //                 return Promise.all([
// //                     db.put(`$field:${field}`, true),
// //                     db.put(`${key}:${field}`, value)
// //                 ]);
// //             };
            
// //             var promises = [];           
// //             if (valueSameAsDeployed) {
// //                 promises.push(put("valueSameAsDeployed", valueSameAsDeployed));
// //             }
// //             if (valueSameAsSetting) {
// //                 promises.push(put("valueSameAsSetting", valueSameAsSetting));
// //             }
// //             if (success) {
// //                 promises.push(put("success", success));
// //             }
// //             promises.push(put(`deployed:${nodeDeploying.port}`, true));
// //             if (deployedPrivateFor) {
// //                 deployedPrivateFor.forEach( node => {
// //                     promises.push(pub(`deployed_private_for:${node.port}`,true));
// //                 });
// //             }

// //             if (nodeSetting) {
// //                 promises.push(put(`setting:${nodeSetting.port}`, true));
// //                 settingPrivateFor.forEach( node => {
// //                     promises.push(put(`deployed_private_for:${node.port}`, true));    
// //                 }); 
// //             }

// //             promises.push(put(`getter:${nodeGetting.port}`, true));
// //             Promise.all(promises).then(n=>{
// //                 resolve()
// //             });
// //         });
// //     }
// // }

//     var run = function(nodesDeploying, deployingPrivateForNodes, nodesSetting, settingPrivateForNodes, nodesGetting) {
//         return new Promise((resolve, reject)=>{  
            
//             var deploying = nodesDeploying.map(node => _.partial(deployContract, node));
//             var deployed = _.flatMap(deployingPrivateForNodes, nodes => {
//                 return deploying.map(fun => fun(nodes))
//             });
//             var checking = function(nodeGetting) {
//                 return function({initialValue, contractDeployed, nodeDeploying, deployedPrivateFor, nodeSet, setPrivateFor }) {
//                     var check = _.partial(getAndCheck, contractDeployed, initialValue, 
//                                         nodeDeploying, deployedPrivateFor, nodeSet, 
//                                         setPrivateFor, nodeSet ? initialValue + 1 : null );
//                     return check(nodeGetting);
//                 }
//             }

//             var callbacksforGettingNodes = nodesGetting.map(checking);

//             var processed = _.flatMap(deployed, deployedContract => callbacksforGettingNodes.map(callback => {
//                 return deployedContract.then(callback);
//             }));
//             //var store = saveToLeveldb('./data.db');

//             // var done = processed.map(p=>{
//             //     return p.then(data=>{
//             //         return store(data);
//             //     });
//             // });
//             var done = processed.map(p=>p.then(data=>{
//                 return saveResult(data);
//             }));
//             return Promise.all(done).then(d=>resolve(d));
//         });
//     }

//     var saveToLeveldb = function(path) {
//         const levelup = require('levelup');
//         const sqldown = require('sqldown');
//         const SQLite = require('sqlite3');
//         const uuid = require('uuid/v1');

//         const sqlite = new SQLite.Database(path, SQLite.OPEN_READWRITE | SQLite.OPEN_CREATE);
//         var db = levelup(sqldown(path));
//         //db.createKeyStream().on('data', db.del);
//         return function(args) {
//             return new Promise(function(resolve, reject) {                                   
//                 var key = uuid();
//                 var put = function([field, value]) {
//                     return Promise.all([
//                         db.put(`$field:${field}`, true),
//                         db.put(`${key}:${field}`, value)
//                     ]);
//                 };
//                 Promise.all(_.entries(args).map(put)).then(d=>{
//                     console.log("done!!")
//                     resolve()
//                 });
//             });
//         }
//     }
//     const fs = require('fs');
//     dbPath = './data.db';
//     console.log(`db created here: ${fs.realpathSync(dbPath)}`)
//     try {
//         fs.unlinkSync(dbPath);
//     } catch {
//         //pass
//     }
//     var store = saveToLeveldb(dbPath);

//     //var result;
//     nodeCombinations.slice(0, 10).forEach(nodeComb => {
//         run(nodes, [nodeComb], [undefined], [undefined], nodes).then(data=>{
//             console.table(data);
//             Promise.all(data.map(store));
//             //Promise.resolve(Promise.all(data.map(store)))
//         }).then(d=>{
//             console.log("success")
//         });
//     })
//     //cant handle large volume. geth node shuts down after a while
//     var result;
//     run(nodes, nodeCombinations.slice(0, 4), [undefined], [undefined], [nodes[0]]).then(data=>{
//         result = data;
//         console.log("done!!!")
//     });
// }



// .map(p=>{}).then(data=>{
//     console.log("done")
//     result = data;
// });

// result.length
// console.table(result)
// console.table(merp);
// Object.keys(merp[0].domain);
// merp[0].then(data=>{
//     console.log(Object.keys(data));
// });
// // ).then(results => {

//     //     console.table(results);
//     // });

//     // function(contractDeployed, deployedValue, nodeDeploying, deployedPrivateFor, 
//     //     settingValue, nodeSetting, settingPrivateFor, 
//     //     nodeGetting) 

//     // deployContract(nodes[0]).then(({initialValue, contractDeployed, nodeDeploying, nodesPrivateFor})=>{
//     //     return getAndCheck(contractDeployed, initialValue, nodeDeploying, nodesPrivateFor, null, null, null, nodes[1]);
//     // }).catch(err=>{
//     //     console.log(err);
//     // }).then(({valueSameAsDeployed, valueSameAsSetting, success, 
//     //         deployedValue, contractDeployed, 
//     //         nodeDeploying, deployedPrivateFor, 
//     //         settingValue, nodeSetting, 
//     //         settingPrivateFor, nodeGetting})=>{
//     //     console.log(nodeGetting.host);
//     // }); 












// function DeployPublicAndCall() {
//     return new Promise(function(resolve, reject) {
//         var value = 1000;
//         var resultsAwaited = nodes.length ** 2;
//         var results = [];
//         nodes.forEach(function(nodeDeploying) {
//             nodeDeploying.web3.personal.unlockAccount(nodeDeploying.web3.eth.accounts[0]);
//             value += 1;
//             var localValue = value;
//             var contractDeployed = nodeDeploying.web3.eth.contract(abi).new(localValue, {
//                 from: nodeDeploying.web3.eth.accounts[0], 
//                 data, 
//                 gas
//             });

//             waitForDeployment(contractDeployed, function() {
//                 nodes.forEach(node=>{
//                     var resultReturnedFromContract = node.web3.eth.contract(abi).at(contractDeployed.address).get.call();
//                     var success = localValue === resultReturnedFromContract.toNumber();
    
//                     var result = {};
//                     result["public_contract"] = true
//                     result["was_set_operation_done"] = false
//                     result[`deployer:${nodeDeploying.port}`] = true;
//                     result["value_deployed_same"] = success;
//                     result[`getter:${node.port}`] = true;
//                     result["success"] = success;
//                     results.push(result);

//                     var description = success ? "success" : "can't find";
//                     console.log(`public contract public call ${description} -> ${nodeDeploying.host} -> ${node.host}`);
//                     resultsAwaited -= 1;
//                     if (resultsAwaited === 0) {
//                         resolve(results);
//                     }
//                 });        
//             });
//         });
//     });
// }

// function DeployPrivateAndCall(nodesAddressed) {
//     var resultsAwaited = nodesAddressed.length * nodes.length;
//     var results = [];
//     return new Promise((resolve, reject)=>{
//         var value = 1000;
//         nodes.forEach(nodeDeploying => {    
//             nodeDeploying.web3.personal.unlockAccount(nodeDeploying.web3.eth.accounts[0]);
//             value += 1;
//             var localValue = value;
//             var contractDeployed = nodeDeploying.web3.eth.contract(abi).new(localValue, {
//                 from: nodeDeploying.web3.eth.accounts[0], 
//                 data, gas, privateFor: _.without(nodesAddressed.map(node=>node.pubkey), nodeDeploying.pubkey)
//             });
//             //console.log(`private contract with all nodes participating public call`);
//             var nodesAddressedMessage = nodesAddressed.map(node=>node.port).join(",") || "none"; 
//             wait(contractDeployed, ()=>{
//                 nodes.forEach(node=>{
//                     var resultFromContract = node.web3.eth.contract(abi).at(contractDeployed.address).get.call().toNumber();
//                     var success = localValue === resultFromContract;
//                     var result = {};
//                     result["public_contract"] = false
//                     nodesAddressed.forEach(nodePrivateFor=> {
//                         result[`deployed-private-for:${nodePrivateFor.port}`] = true
//                     });
//                     result["was_set_operation_done"] = false;
//                     result[`deployer:${nodeDeploying.port}`] = true;
//                     result["value_deployed_same"] = success;
//                     result[`getter:${node.port}`] = true;
//                     result["success"] = success;
//                     results.push(result);
//                     var resultString = success ? "success" : "-------";
//                     console.log(`${nodesAddressedMessage} ${resultString} ${nodeDeploying.host} -> ${node.host}`);
//                     console.log(`${resultsAwaited} === ${results.length}`);
//                     if (resultsAwaited === results.length) {
//                         resolve(results);
//                     }
//                 });        
//             });
//         });
//     });
// }

// var res = [];
// DeployPublicAndCall().then(result=>{
//     console.log("done");
//     console.log(result);
//     res.push(result);
// });

// Promise.all(nodeCombinations.slice(0, 10).map(comb => DeployPrivateAndCall(comb))).then(result=>{
//     res.push(result);
// })

// DeployPrivateAndCall(allNodes)
// DeployPrivateAndCall([])

// var c;
// nodeCombinations.forEach(function(comb) {
//     c = comb;
//     console.log(comb);
// //    DeployPrivateAndCall(comb);
// });
// DeployPrivateAndCall(c);


// var deployAccount = nodes[0].web3.eth.accounts[0];
// nodes[0].web3.personal.unlockAccount(deployAccount);

// var initialValue = 42;
// var contractDeployed = nodes[0].web3.eth.contract(abi).new(initialValue, {
//     from: deployAccount, 
//     data, 
//     gas, 
//     privateFor: [nodes[3].pubkey]
// });

// nodes.forEach(node=>{
//     var result = node.web3.eth.contract(abi).at(contractDeployed.address).get.call();
//     console.log(`${initialValue == result.toNumber()} -> ${node.host}`);
// });

// var value = 442;
// var from = nodes[0].web3.eth.accounts[0];
// nodes[0].web3.personal.unlockAccount(from);
// nodes[0].web3.eth.contract(abi).at(contractDeployed.address).set.sendTransaction(value, { from, gas });

// console.log(`initial "${value}": public transaction to private contract (node 1 + 4)`)
// nodes.forEach(node=>{
//     var from = node.web3.eth.accounts[0];
//     var hostSetting = node.host;
//     node.web3.personal.unlockAccount(from);
//     value += 1;
//     node.web3.eth.contract(abi).at(contractDeployed.address).set.sendTransaction(value, {from, gas});
//     nodes.forEach(node=>{
//         var result = node.web3.eth.contract(abi).at(contractDeployed.address).get.call();
//         console.log(`${value} -> ${node.host} -> ${result.toString()}`);
//     });
// });

// var value = 3441;
// var from = nodes[0].web3.eth.accounts[0];
// nodes[0].web3.personal.unlockAccount(from);
// nodes[0].web3.eth.contract(abi).at(contractDeployed.address).set.sendTransaction(value, { from, gas });

// console.log(`initial "${value}": private transaction (1 + 4) to private contract (node 1 + 4)`);
// var privateFor = _.at(nodes, [0, 3]).map(node=>node.pubkey);
// nodes.forEach(node=>{
//     var from = node.web3.eth.accounts[0];
//     var privateFor = _.without(privateFor, node.pubkey);
//     var hostSetting = node.host;
//     value += 1;
//     node.web3.personal.unlockAccount(from);
//     node.web3.eth.contract(abi).at(contractDeployed.address).set.sendTransaction(value, {from, gas, privateFor});
//     nodes.forEach(node=>{
//         var result = node.web3.eth.contract(abi).at(contractDeployed.address).get.call();
//         console.log(`${value} -> ${hostSetting} -> ${node.host} -> ${result.toString()}`);
//     });
// });

// var a = [0, 1, 2, 3];
// var indices = a.map(n=>[n]);
// indices.push(
//     a.map(n=>[a.map(m=>[n,m])])
// );




// //var pubkeyCombinations = r.map(c=>_.at(nodes.map(n=>n.pubkey), c))

// r.map(c=>_.at(nodes.map(n=>n.pubkey), c)).forEach(privateFor => {
//     var value = _.random(10, 1000000);
//     var from = nodes[0].web3.eth.accounts[0];
//     nodes[0].web3.personal.unlockAccount(from);
//     nodes[0].web3.eth.contract(abi).at(contractDeployed.address).set.sendTransaction(value, { from, gas });
    
//     console.log(`initial "${value}": private transaction (1 + 4) to private contract (node 1 + 4)`);
//     var privateFor = _.at(nodes, [0, 3]).map(node=>node.pubkey);
//     nodes.forEach(node=>{
//         var from = node.web3.eth.accounts[0];
//         var privateFor = _.without(privateFor, node.pubkey);
//         var hostSetting = node.host;
//         value += 1;
//         node.web3.personal.unlockAccount(from);
//         node.web3.eth.contract(abi).at(contractDeployed.address).set.sendTransaction(value, {from, gas, privateFor});
//         nodes.forEach(node=>{
//             var result = node.web3.eth.contract(abi).at(contractDeployed.address).get.call();
//             console.log(`${value} -> ${hostSetting} -> ${node.host} -> ${result.toString()}`);
//         });
//     });
// });



// nodes[0].web3.eth.contract(abi).at(contractDeployed.address).get.call()
// nodes[1].web3.eth.contract(abi).at(contractDeployed.address).get.call()
// nodes[2].web3.eth.contract(abi).at(contractDeployed.address).get.call()
// nodes[3].web3.eth.contract(abi).at(contractDeployed.address).get.call()





// var rpcEndpoint = "http://localhost:8001";
// var web3 = new Web3();
// var provider = new web3.providers.HttpProvider(rpcEndpoint);
// web3.setProvider(provider);
// //var quorumjs = require("quorum-js");
// var from = web3.eth.accounts[0]
// web3.eth.defaultAccount = from;


// var privateFor = [_.values(_.omit(privateKeys, rpcEndpoint))[0]];  


// var simpleContract = web3.eth.contract(abi);
// web3.personal.unlockAccount(from);
// // var simple = simpleContract.new(42, opts, function(e, contract) {
// //     //console.log(contract);
// //     // if (e) {
// //     //     reject(e);
// //     // } else {
// //     //     resolve(contract);
// //     // }
// // });

// new Promise(function (resolve, reject) {
//     simpleContract.new(42, opts, function(e, contract) {
//         //console.log(contract);
//         // if (e) {
//         //     reject(e);
//         // } else {
//         //     resolve(contract);
//         // }
//     });
// }).then(data=>{
//     console.log("===================");
//     console.log(data);
//     // if (data.address) {
//     //     return data.address;
//     // } else {
//     //     filter = web3.eth.filter("latest");
//         //return new Promise(function(resolve, reject) {
//         //    resolve("something");
//             // console.log("=======================");
//             // filter.watch(function(error, result) {
//             //     console.log("=======================");
//             //     if (error) {
//             //         reject(error);
//             //     }
//             //     var tx = web3.eth.getTransactionReceipt(data.transactionHash);
//             //     if (tx && tx.contractAddress) {
//             //         resolve(tx.contractAddress);
//             //         filter.stopWatching();
//             //     }
//             // });
//         //});
// //    }
// }).catch(err=>{
//     console.log(err);
// }).then(address =>{
//     console.log(`address: ${address}`);
// });

// // transactionHash
// // address
// // if (!contract.address) {
// //     console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");
// // } else {
// //     console.log("Contract mined! Address: " + contract.address);
// //     console.log(contract);
// // }



// a = web3.eth.accounts[0]
// web3.eth.defaultAccount = a;

// // abi and bytecode generated from simplestorage.sol:
// // > solcjs --bin --abi simplestorage.sol
// var abi = [{"constant":true,"inputs":[],"name":"storedData","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"x","type":"uint256"}],"name":"set","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"get","outputs":[{"name":"retVal","type":"uint256"}],"payable":false,"type":"function"},{"inputs":[{"name":"initVal","type":"uint256"}],"payable":false,"type":"constructor"}];

// var bytecode = "0x6060604052341561000f57600080fd5b604051602080610149833981016040528080519060200190919050505b806000819055505b505b610104806100456000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680632a1afcd914605157806360fe47b11460775780636d4ce63c146097575b600080fd5b3415605b57600080fd5b606160bd565b6040518082815260200191505060405180910390f35b3415608157600080fd5b6095600480803590602001909190505060c3565b005b341560a157600080fd5b60a760ce565b6040518082815260200191505060405180910390f35b60005481565b806000819055505b50565b6000805490505b905600a165627a7a72305820d5851baab720bba574474de3d09dbeaabc674a15f4dd93b974908476542c23f00029";

// var simpleContract = web3.eth.contract(abi);
// //_.entries(_.omit(privateKeys, rpcEndpoint)).forEach( pair => {
// [_.entries(privateKeys)[1]].forEach( pair => {
//     web3.personal.unlockAccount(web3.eth.accounts[0]);
//     var host = pair[0];
//     var pubkey = pair[1];
//     var simple = simpleContract.new(42, {from:web3.eth.accounts[0]
//                                         ,data: bytecode
//                                         ,gas: 0x47b760
//                                         ,privateFor: [pubkey]}
//                                         ,function(e, contract) {
//         console.log("==================================" + host);
//         console.log("==================================" + pubkey);
//         if (e) {
//             console.log("err creating contract", e);
//         } else {
//             // if (!contract.address) {
//             //     console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");
//             // } else {
//             //     console.log("Contract mined! Address: " + contract.address);
//                 console.log("=================================");
//                 console.log(simple.get.call({from:web3.eth.accounts[0]}));
//             // }
//         }
//     });
// });

// var host = h;
// console.log(h);
//     // web3.personal.unlockAccount(web3.eth.accounts[0]);
//     // var simple = simpleContract.new(42, {from:web3.eth.accounts[0]
//     //                                     ,data: bytecode
//     //                                     ,gas: 0x47b760
//     //                                     ,privateFor: [privateKeys[host]]}
//     //                                     ,function(e, contract) {
//     //     console.log("==================================" + host);
//     //     console.log("==================================" + privateKeys[host]);
//     //     // if (e) {
//     //     //     console.log("err creating contract", e);
//     //     // } else {
//     //     //     if (!contract.address) {
//     //     //         console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");
//     //     //     } else {
//     //     //         console.log("Contract mined! Address: " + contract.address);
//     //     //         console.log(contract);
//     //     //     }
//     //     // }
//     // });
// }

// privateKeys.forEach(key => {
//     web3.personal.unlockAccount(a);
//     var simple = simpleContract.new(42, {from:web3.eth.accounts[0], data: bytecode, gas: 0x47b760, privateFor: [key]}, function(e, contract) {
//         console.log("==================================" + key);
//         if (e) {
//             console.log("err creating contract", e);
//         } else {
//             if (!contract.address) {
//                 console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");
//             } else {
//                 console.log("Contract mined! Address: " + contract.address);
//                 console.log(contract);
//             }
//         }
//     });
// });

// //////////////////////////////////////////////////////////////////
// //////////////////////////////////////////////////////////////////
// //////////////////////////////////////////////////////////////////
// //////////////////////////////////////////////////////////////////

// a = web3.eth.accounts[0]
// web3.eth.defaultAccount = a;

// // abi and bytecode generated from simplestorage.sol:
// // > solcjs --bin --abi simplestorage.sol
// var abi = [{"constant":true,"inputs":[],"name":"storedData","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"x","type":"uint256"}],"name":"set","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"get","outputs":[{"name":"retVal","type":"uint256"}],"payable":false,"type":"function"},{"inputs":[{"name":"initVal","type":"uint256"}],"payable":false,"type":"constructor"}];

// var bytecode = "0x6060604052341561000f57600080fd5b604051602080610149833981016040528080519060200190919050505b806000819055505b505b610104806100456000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680632a1afcd914605157806360fe47b11460775780636d4ce63c146097575b600080fd5b3415605b57600080fd5b606160bd565b6040518082815260200191505060405180910390f35b3415608157600080fd5b6095600480803590602001909190505060c3565b005b341560a157600080fd5b60a760ce565b6040518082815260200191505060405180910390f35b60005481565b806000819055505b50565b6000805490505b905600a165627a7a72305820d5851baab720bba574474de3d09dbeaabc674a15f4dd93b974908476542c23f00029";

// var filter = web3.eth.filter('latest');
// filter.watch(console.log);
// //function(error, result){
// //    console.log("=================");
//     // console.log(JSON.stringify(result));
//     // console.log(JSON.stringify(result).replace(/^/gm, "new block mined: "));
//     // filter.stopWatching();
// //});
// filter.stopWatching();


// var simpleContract = web3.eth.contract(abi);
// var opts = {
//     from:web3.eth.accounts[0], 
//     data: bytecode, 
//     gas: 0x47b760, 
//     privateFor: ["rZpUaM5y4yk3qbAchczsFpSX+RmJHpLho8eAxf2h6Do="]
// };

// var a = 0;
// var checkTx = function() {
//     //var address = web3.eth.getTransactionReceipt(tx).contractAddress;
//     a += 1;
//     //if (address) {
//     if (a > 3) {
//         console.log("returning");
//         return a;
//         //return address         
//     } else {
//         console.log("debouncing");
//         var d = _.debounce(checkTx, 1000)();
//         console.log(d); 
//         return d;
//     }
// }
// //old transaction private => '0xabab2e6cf56da7a9dc4ff9b5625ea6ac2ea2f80d1194b20f6a42e74e160c0180'

// var async = require("async")

// task(callback(err, result), results)

// var a = 0;
// var f = (callback, result) => {
//     a += 1;
//     console.log(a);
//     if ( a > 3 ) {
//         callback(null, a);
//     } else {
//         callback("yes");
//     }
// }


// var apiMethod = () => {
//     console.log(a);
//     ++a;
// }
// async.until(() => a > 3, apiMethod)

// var a = 0;
// var f = () => {
//     if(a<5) {
//         setTimeout(function () {
//             a += 1;
//             console.log(a);
//             f();
//         }, 1000);
//     }
// }
// f();

// var count = 0;

// async.whilst(
//     function () { return count < 5; },
//     function (callback) {
//         console.log(count)
//         count++;
//         setTimeout(function () {
//             callback(null, count);
//         }, 1000);
//     },
//     function (err, n) {
//         console.log(err, n)
//         // 5 seconds have passed, n = 5
//     }
// );

// console.log("herp")

// async.retry({times: 5, interval: 2000}, function(callback, result) {
//     apiMethod();
//     console.log(`result ${[...arguments]}`);
//     if ( a > 3 ) {
//         callback("no", a);
//     } else {
//         callback("yes");
//     }
//     return a;
// });

// //////////////////////////////////////////////////////////////
// //////////////////////////////////////////////////////////////
// var Web3 = require("web3");
// var privateKeys = {"http://localhost:8001": "/Z1+Fe3tRAf+lyyXKZCil8pkSebWW+O0XELGRNquIlE=",
//                    "http://localhost:8002": "3f/cPMz+tu1bPUXRgGjNVFbWQly45ix9s6STZYQ8Dh4=",
//                    "http://localhost:8003": "rZpUaM5y4yk3qbAchczsFpSX+RmJHpLho8eAxf2h6Do=",
//                    "http://localhost:8004": "WC0NbFD3f3bSOymsNTWYuCvIi3gWeOCU6DKqDpqBexU="};

// var _ = require("lodash");
// var rpcEndpoint = "http://localhost:8001";
// var web3 = new Web3();
// var provider = new web3.providers.HttpProvider(rpcEndpoint);
// web3.setProvider(provider);
// //var quorumjs = require("quorum-js");
// var from = web3.eth.accounts[0]

// var abi = [{"constant":true,"inputs":[],"name":"storedData","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"x","type":"uint256"}],"name":"set","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"get","outputs":[{"name":"retVal","type":"uint256"}],"payable":false,"type":"function"},{"inputs":[{"name":"initVal","type":"uint256"}],"payable":false,"type":"constructor"}];
// var bytecode = "0x6060604052341561000f57600080fd5b604051602080610149833981016040528080519060200190919050505b806000819055505b505b610104806100456000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680632a1afcd914605157806360fe47b11460775780636d4ce63c146097575b600080fd5b3415605b57600080fd5b606160bd565b6040518082815260200191505060405180910390f35b3415608157600080fd5b6095600480803590602001909190505060c3565b005b341560a157600080fd5b60a760ce565b6040518082815260200191505060405180910390f35b60005481565b806000819055505b50565b6000805490505b905600a165627a7a72305820d5851baab720bba574474de3d09dbeaabc674a15f4dd93b974908476542c23f00029";


// var simpleContract = web3.eth.contract(abi);

// var opts = {
//     from:web3.eth.accounts[0], 
//     data: bytecode, 
//     gas: 0x47b760, 
//     privateFor: ["rZpUaM5y4yk3qbAchczsFpSX+RmJHpLho8eAxf2h6Do="]
// };

// //var opts = _.omit(opts, "privateFor");

// _.entries(privateKeys).forEach(pair=>{

//     var web3 = new Web3();
//     var provider = new web3.providers.HttpProvider(pair[0]);
//     web3.setProvider(provider);
//     web3.personal.unlockAccount(web3.eth.accounts[0]);
//     //var contract = simpleContract.at(address);
//     var numberToStore = 10000 + parseInt(pair[0].split(":").pop());
//     //var newOpts = _.set(opts, "privateFor", _.values(_.omit(privateKeys, pair[1])));
//     //var newOpts = _.set(opts, "privateFor", [pair[1]]);
//     var opts = {
//         from: web3.eth.accounts[0], 
//         gas: 0x47b760, 
//         privateFor: ["rZpUaM5y4yk3qbAchczsFpSX+RmJHpLho8eAxf2h6Do="]
//     };
    
//     var newOpts = opts;

//     var simple;
//     var address;
//     try {
//         simple = simpleContract.new(numberToStore, newOpts)
//         address = web3.eth.getTransactionReceipt(simple.transactionHash).contractAddress;
//     } catch {
//         console.log("dind't work");    
//         return;
//     }
//     console.log(`new ${numberToStore} {"${pair[0]}": "${pair[1]}"}`);

//     _.entries(privateKeys).forEach(pair=>{
//         var hostSetting = pair[0];
//         var pubkeySetting = pair[1];
        
//         var web3 = new Web3();
//         var provider = new web3.providers.HttpProvider(hostSetting);
//         web3.setProvider(provider);
//         web3.personal.unlockAccount(web3.eth.accounts[0]);
//         var contract = simpleContract.at(address);
//         var numberToStore = parseInt(hostSetting.split(":").pop());
//         var newOpts = _.set(opts, "privateFor", [pubkeySetting]);
//         try {
//             contract.set.sendTransaction(numberToStore, newOpts);
//             console.log(`  set ${numberToStore} {"${hostSetting}": "${pubkeySetting}"}`);
//         } catch {
//             console.log(` cant set {"${hostSetting}": "${pubkeySetting}"}`);
//         }    
//         _.entries(privateKeys).forEach(pair=>{
//             var web3 = new Web3();
//             var provider = new web3.providers.HttpProvider(pair[0]);
//             web3.setProvider(provider);
//             web3.personal.unlockAccount(web3.eth.accounts[0]);
//             var contract = simpleContract.at(address);
//             var newOpts;
//             if (pair[1] === pubkeySetting) {
//                 newOpts = _.set(opts, "privateFor", [pair[1]]);
//             } else {
//                 newOpts = _.omit(opts, "privateFor");
//             }
//             try {
//                 var result = contract.get.call(_.set(opts, "privateFor", pair[1])).toString();
//                 console.log(`    ${result} <-- {"${pair[0]}": "${pair[1]}"}`);
//             } catch {
//                 console.log(`    didn't work <-- {"${pair[0]}": "${pair[1]}"}`);
//             }    
//         });   
//     });
// });

// //simple.transactionHash
// await async.retry({times: 30, interval: 2000}, (callback, result) =>{
//     web3.eth.getTransactionReceipt(c.transactionHash);

// }, function(err, result) {
//     console.log(result);
// });




// web3.personal.unlockAccount(web3.eth.accounts[0]);
// var simple = simpleContract.new(42, opts)
// Object.keys(simple);
// simple.transactionHash

// , function(e, contract) {
// 	if (e) {
// 		console.log("err creating contract", e);
// 	} else {
// 		if (!contract.address) {
//             var get = simpleContract.at(web3.eth.getTransactionReceipt(contract.transactionHash).contractAddress).get.call().toString();
//             console.log(get);
//             //console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");
//             //console.log(Object.keys(contract));
// 		} else {
// 			console.log("Contract mined! Address: " + contract.address);
// 			console.log(contract);
// 		}
// 	}
// });

