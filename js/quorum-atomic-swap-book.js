var Web3 = require("web3");
var _ = require("lodash");
var generateSecret = function() {
    return Math.random().toString(36).substr(2, 9);
}

function Bank(abbreviation) {
    if (!Bank.reg) {
        Bank.reg = [];
    } 
    Bank[abbreviation.toLowerCase()] = this;
    this.abbreviation = abbreviation;
    Bank.reg.push(this);
    return this;
}

(banks => [8001, 8002, 8003, 8004].forEach(port => {
    var [abbr, desc] = banks.pop();
    var bank = new Bank(abbr);
    bank.web3 = new Web3(new Web3.providers.HttpProvider(`http://localhost:${port}`));
    bank.host = `http://localhost:${port}`;
    bank.description = desc;
}))([["RBI", "Reserve Bank of India"],["FRS", "Federal Reserve System"],["BOA", "American bank"],["ICICI", "Indian bank"]]);

var counts = Bank.reg.reduce((prev, curr) =>{
    curr.web3.eth.accounts.forEach(acc =>{
        var references = prev[acc];
        if (references) {
            prev[acc] += 1;
        } else {
            prev[acc] = 1;
        }
    });
    return prev;
}, {});

for (key in counts) {
    if (counts[key] === 4) {
        Bank.fundedAccount = key;
        break;
    }
}

Bank.reg.forEach(bank => {
    bank.address = _.find( bank.web3.eth.accounts, account => account !== Bank.fundedAccount);
});

Bank.addresses = {};
Bank.reg.forEach(bank => {
    Bank.addresses[bank.address] = bank.abbreviation;
})
Bank.addresses[Bank.fundedAccount] = "common account";

(curs => curs.forEach(cur =>{
    Bank[`${cur}Balances`] = function() {
        return _.mapValues(Bank.addresses, (value, key) =>{
            var randomNode = Bank.reg[0];
            var contractName = `atomicSwap${cur.slice(0, 1).toUpperCase() + cur.slice(1)}`;
            var contract = randomNode[contractName]();
            //var methodName = `get${cur.toUpperCase()}Balance`;
            //var methodName = "balances";
            var method = contract.balances.call
            return method(key);
        });
    }
    Bank[`print${cur.slice(0, 1).toUpperCase()}${cur.slice(1)}Balances`] = function(viewAll) {
        var count = 0;
        _.forEach(Bank[`${cur}Balances`](), (value, key) => {
            if (viewAll || value.toString() !== '0') {
                count += 1;
                console.log(`${Bank.addresses[key]}'s ${cur} balances: ${value.toString()}`)
            }
        });
        if (count === 0) {
            if (viewAll) {
                console.log(`no addresses to check${cur} balances: ${value.toString()}`)
            } else {
                console.log(`no balances for ${cur.toUpperCase()}`)
            }
        }
    }        
    Bank[`${cur}Allowances`] = function() {
        return _.mapValues(Bank.addresses, (value, allowingAddress) =>{
            return _.mapValues(Bank.addresses, (value, allowedAddress) =>{
                var randomNode = Bank.reg[0];
                var contractName = `atomicSwap${cur.slice(0, 1).toUpperCase() + cur.slice(1)}`;
                var contract = randomNode[contractName]();
                //var methodName = `get${cur.toUpperCase()}Balance`;
                //var methodName = "balances";
                var method = contract.allowed.call;
                var result = method(allowingAddress, allowedAddress);
                return result.toString();
            });
        });
    }
    Bank[`print${cur.slice(0, 1).toUpperCase()}${cur.slice(1)}Allowances`] = function(viewAll) {
        var count = 0;
        _.forEach(Bank[`${cur}Allowances`](), (valueAllowing, addressAllowing) => {
            _.forEach(valueAllowing, (valueAllowed, addressAllowed) => {
                if (viewAll || valueAllowed.toString() !== '0') {
                    count += 1;
                    var allowing = Bank.addresses[addressAllowing];
                    var allowed = Bank.addresses[addressAllowed];
                    console.log(`${allowing}'s allowed ${allowed} ${cur} balances: ${valueAllowed.toString()}`)
                }
            });
        });
        if (count === 0) {
            if (viewAll) {
                console.log(`no addresses to check${cur} allowances: ${value.toString()}`)
            } else {
                console.log(`no allowances for ${cur.toUpperCase()}`)
            }
        }
    }    
}))(["usd", "inr"]);


var solc = require("solc");
var code = `pragma solidity ^0.5.3;
contract Debuggable { event Debug(string what);}
`;
code += ['inr', 'usd'].reduce( (prev, ccy) => prev + `
contract ${ccy.toUpperCase()} { 
    event DebugAddress(address who, string message);
    event DebugUint(uint what, string message);
    mapping (address => uint) public balances; 
    mapping (address => mapping (address => uint)) public allowed; 
    address public owner; 
    event issue${ccy.toUpperCase()}Call(address to, uint amount);
    event transfer${ccy.toUpperCase()}Call(address to, uint amount);
    event transfer${ccy.toUpperCase()}FromCall(address from, address to, uint amount);
    event approveCall(address spender, uint amount);
    event tick(string message);
    constructor() public {
        owner = msg.sender;
    }
    function issue${ccy.toUpperCase()}(address to, uint amount) public { 
        emit issue${ccy.toUpperCase()}Call(to, amount); 
        emit DebugAddress(msg.sender, "who issues call");
        emit DebugAddress(owner, "owner");
        if(msg.sender == owner) { 
            balances[to] += amount; 
        } 
    } 
    function transfer${ccy.toUpperCase()}(address to, uint amount) public { 
        emit transfer${ccy.toUpperCase()}Call(to, amount);
        emit DebugUint(balances[msg.sender], "balances[msg.sender]");
        emit DebugUint(amount, "amount to transfer"); 
        emit DebugAddress(to, "recipient"); 
        emit DebugAddress(msg.sender, "sender"); 
        if (balances[msg.sender] >= amount) { 
            balances[msg.sender] -= amount; 
            emit DebugUint(balances[to], "balance pretransfer");
            balances[to] += amount; 
            emit DebugUint(balances[to], "balance posttransfer");
    } } 
    function get${ccy.toUpperCase()}Balance(address account) public view returns (uint) { 
        return balances[account]; 
    } 
    function approve(address spender, uint amount) public { 
        emit approveCall(spender, amount);
        allowed[spender][msg.sender] = amount; 
    } 
    function transfer${ccy.toUpperCase()}From(address from, address to, uint amount) public { 
        emit transfer${ccy.toUpperCase()}FromCall(from, to, amount); 
        if(allowed[msg.sender][from] >= amount && balances[from] >= amount) { 
            allowed[msg.sender][from] -= amount; 
            balances[from] -= amount; 
            balances[to] += amount; 
        } 
    }
}
contract AtomicSwap_${ccy.toUpperCase()} is ${ccy.toUpperCase()},Debuggable { 
    struct AtomicTxn { 
        address from; 
        address to; 
        uint lockPeriod; 
        uint amount; } 
    mapping (bytes32 => AtomicTxn) public txns;  
    event lockCall(address to, bytes32 hash, uint lockExpiryMinutes, uint amount);
    event ${ccy.toLowerCase()}Locked(address to, bytes32 hash, uint expiryTime, uint amount); 
    event ${ccy.toLowerCase()}Unlocked(bytes32 hash); 
    event ${ccy.toLowerCase()}Claimed(string secret, address to, address from, bytes32 hash); 
    event UintPass(uint uintInQuestion);
    constructor(address ${ccy.toLowerCase()}ContractAddress) ${ccy.toUpperCase()}() public { 
    //    super.owner = msg.sender;
    //     emit Debug("constructor(address usdContractAddress) public {"); 
    //     ${ccy.toUpperCase()}Contract = ${ccy.toUpperCase()}(${ccy.toLowerCase()}ContractAddress);
    //     ${ccy.toUpperCase()}Contract.merp(); 
    //     emit Debug("${ccy.toUpperCase()}Contract = ${ccy.toUpperCase()}(${ccy.toLowerCase()}ContractAddress);"); 
    } 
    function lock15(address to, bytes32 hash, uint amount) public { 
        emit UintPass(amount);
        uint lockExpiryMinutes = 15;
        emit lockCall(to, hash, lockExpiryMinutes, amount);
        super.transfer${ccy.toUpperCase()}From(msg.sender, address(this), amount); 
        txns[hash] = AtomicTxn(msg.sender, to, block.timestamp + (lockExpiryMinutes * 60), amount); 
        emit ${ccy.toLowerCase()}Locked(to, hash, block.timestamp + (lockExpiryMinutes * 60), amount); 
    }
    function lock30(address to, bytes32 hash, uint amount) public { 
        emit UintPass(amount);
        uint lockExpiryMinutes = 30;
        emit lockCall(to, hash, lockExpiryMinutes, amount);
        super.transfer${ccy.toUpperCase()}From(msg.sender, address(this), amount); 
        txns[hash] = AtomicTxn(msg.sender, to, block.timestamp + (lockExpiryMinutes * 60), amount); 
        emit ${ccy.toLowerCase()}Locked(to, hash, block.timestamp + (lockExpiryMinutes * 60), amount); 
    }
    function claim(string memory secret) public { 
        emit Debug("function claim(str..."); 
        bytes32 hash = keccak256(bytes(secret)); 
        emit Debug("bytes32 hash = sha2"); 
        super.transfer${ccy.toUpperCase()}(txns[hash].to, txns[hash].amount); 
        emit Debug("${ccy.toUpperCase()}Contract.transferUS"); 
        emit ${ccy.toLowerCase()}Claimed(secret, txns[hash].to, txns[hash].from, hash); } 
        function calculateHash(string memory secret) public returns (bytes32) { 
              return keccak256(bytes(secret)); }}
`, '');

var compiled = (content => {
    (msg => {
        console.log("=".repeat(msg.length));
        console.log(msg);
    })(`solc version: ${solc.version()}`);
    
    var input = { language: 'Solidity', sources: { 'all.sol': { content } }, settings: { outputSelection: { '*': { '*': [ '*' ] } } } };
    return JSON.parse(solc.compile(JSON.stringify(input)));
})(code);

if (compiled.errors) {
    compiled.errors.forEach(err => {
        console.error(`${err.severity}: ${err.formattedMessage}`)
    });
    if (compiled.errors.filter(err=>err.severity !== "warning").length) {
        console.error("FATAL ERROR".padEnd("=", 20));
        process.exit();
    }
}

var waitForTx = ((banks, triesAttempted, waitMilliseconds) => txHashes  => {
    var waitForIndividualTransaction = txHash => new Promise( (resolve, reject) => {        
        var tries = triesAttempted;
        var tried = 0;
        var waitForAddress = () => setTimeout( () => {
            var txs = banks.map(bank => bank.web3.eth.getTransaction(txHash));
            var txsConfirmed = _.every(txs,tx => tx && tx.blockNumber);
            if (txsConfirmed) {
                return resolve(banks[0].web3.eth.getTransactionReceipt(txHash));
            } else {
                tries -= 1;
                tried += 1;
                console.log(`tried ${(waitMilliseconds * tried)/1000} seconds`);
                if (tries === 0) {
                    return reject("timeout");
                } else {
                    return waitForAddress();
                }
            }
        }, waitMilliseconds);
        return waitForAddress();
    });
    if (Array.isArray(txHashes)) {
        return Promise.all(txHashes.map(waitForIndividualTransaction));
    } else {
        //console.log(`txhash: ${txHashes}`);
        return waitForIndividualTransaction(txHashes);
    }
})(Bank.reg, 100, 2000);

var distributeFundsAcross = (banks => () => {
    var from = banks.fundedAccount;
    return Promise.all(banks.reg.map(node => {
        node.web3.personal.unlockAccount(from, ()=>{
        var to = node.address;
            var gasPrice = '0x00';
            var gasLimit = '0x47b760';
            var value = 1000;
            return new Promise((resolve, reject) => {
                var opts = { gasPrice, gasLimit, value, from, to };
                var txHash = node.web3.eth.sendTransaction(opts);
                waitForTx(txHash).then(data => resolve(to)).catch(reject);
            });
        });
    }));
})(Bank);

var deployContracts = (pairs => (banks, contracts) => () => Promise.all(pairs.map(([currencyAbbr, bankName]) => {
    var deploy = _.partial(function (deployerBank, compiledContract, address) {
        var {abi} = compiledContract;
        //var abi = JSON.parse(compiledContract.interface);
        var bytecode = '0x' + compiledContract.evm.bytecode.object;
        console.log(`Total gas cost: ${compiledContract.evm.gasEstimates.creation.totalCost}`);
        //console.log(bytecode);
        return new Promise(function(resolve, reject) {
            deployerBank.web3.personal.unlockAccount(deployerBank.address, function() {                var from = deployerBank.address; 
                var data = bytecode;
                var gas = "4700000";
                var gasPrice = '0x00';
                var gasLimit = '0x47b760';
                var opts = { from, data, gas, gasPrice, gasLimit };
                var txHash = deployerBank.web3.eth.contract(abi).new(address, opts).transactionHash; 
                waitForTx(txHash).then(function(txRec) {
                    var addressDeployed = txRec.contractAddress;
                    var contractName = _.camelCase(JSON.parse(compiledContract.metadata).settings.compilationTarget['all.sol']);
                    console.log(`deployed ${contractName} ${addressDeployed} with addr ${address}`)
                    banks.prototype[contractName] = function() { 
                        return this.web3.eth.contract(abi).at(addressDeployed); 
                    };
                    banks.addresses[addressDeployed] = contractName;
                    return resolve(addressDeployed);
                });
            });
        });
    }, banks[bankName]);
    var firstContract = contracts[`${currencyAbbr}`];
    var secondContract = _.partial(deploy, contracts[`AtomicSwap_${currencyAbbr}`]);
    return deploy(firstContract).then(secondContract);
})))([["INR", "rbi"],["USD", "frs"]])(Bank, compiled.contracts['all.sol']);

var issueCurrency = () => {
    var issue = ([regulator, recipient, issueMethod]) => {
        regulator.web3.personal.unlockAccount(regulator.address)
        var txHash = issueMethod.sendTransaction(recipient.address, 1000, {
            from: regulator.address, 
            gasPrice: '0x00', 
            gasLimit: '0x47b760'
        });
        return waitForTx(txHash);
    };
    var usd = [frs, boa, frs.atomicSwapUsd().issueUSD];
    var inr = [rbi, icici, rbi.atomicSwapInr().issueINR];
    var promises = [usd, inr].map(issue);
    return Promise.all(promises);
};

var approve = () => Promise.all([[frs, boa, frs.atomicSwapUsd(), boa.atomicSwapUsd().approve], 
                                 [rbi, icici, rbi.atomicSwapInr(), icici.atomicSwapInr().approve]].map(([regulator, approver, swapContract, approveMethod]) => new Promise((resolve, reject) => {
    var process = (e, txnHash) => e ? reject(e) : resolve(txnHash);
    approver.web3.personal.unlockAccount(approver.address);
    approveMethod.sendTransaction(swapContract.address, 1000, {from: approver.address, gasPrice: '0x00', gasLimit: '0x47b760'}, process);
}).then(txhash => waitForTx(txhash))));

var {frs, boa, icici, rbi} = Bank;
var secret = generateSecret();

// var lock = ((secret/*, minutes*/, value, gas) => (transactingBank, sourceBank) => () => new Promise( (resolve, reject) => {
//     transactingBank.web3.personal.unlockAccount(transactingBank.address, () => {
//         var hash = transactingBank.atomicSwapUsd().calculateHash.call(secret, {from: transactingBank.address});
//         var opts = {from: transactingBank.address, gas, gasPrice: '0x00', gasLimit: '0x47b760'};
//         //var process = (e, txnHash) => e ? reject(e) : resolve(txnHash);
//         transactingBank.web3.personal.unlockAccount(transactingBank.address, () => {
//             transactingBank.atomicSwapUsd().lock30.sendTransaction(sourceBank.address, hash/*, minutes*/, value, opts, (e, txHash) => {
//                 waitForTx(txHash).then(resolve).catch(reject);
//             });
//         });
//     });
// }).then())(secret/*, 30*/, "1000", 4712388);

var tapInto = ((cur) => () => new Promise( (resolve, reject) => {
    var currencies;
    if (Array.isArray(cur)) {
        currencies = cur;
    } else {
        currencies = [cur];
    }
    currencies.forEach( cur => {
        var range = {fromBlock:0, toBlock:"latest"};
        var node = Bank.reg[0];
        var contractName = `atomicSwap${cur.slice(0, 1).toUpperCase() + cur.slice(1)}`;
        var contract = node[contractName]();
        contract.allEvents(range).watch(function (err, result) {
            if (err) {console.log(err);}
            var args = _.mapValues(result.args, (value, key) =>{
                if (Bank.addresses[value]) {
                    return Bank.addresses[value];
                } else {
                    return value;
                }
            })
            console.log(`${result.event} ${JSON.stringify(args)}`)
        });
    });
    resolve();
}))(["usd", "inr"]);

var lock = () => {
    console.log("lock".padEnd(20, "="));
    var combinations = [
        [boa, icici, boa.atomicSwapUsd().lock30, 1000],
        [icici, boa, icici.atomicSwapInr().lock15, 1000]
    ];
    var processLock = ([who, where, lockFun, value]) => new Promise( (resolve, reject) => {
        who.web3.personal.unlockAccount(who.address, () => {
            var hash = who.atomicSwapUsd().calculateHash.call(secret, {from: who.address, gas: 4712388, gasPrice: '0x00', gasLimit: '0x47b760'});
            var txHash = lockFun.sendTransaction(where.address, hash, value, {from: who.address, gas: 4712388, gasPrice: '0x00', gasLimit: '0x47b760'})
            waitForTx(txHash).catch(reject).then(resolve);
        });
    });
    return combinations.reduce((prev, cur) =>{
        if (!prev) {
            return processLock(cur);
        } else {
            return prev.then(processLock(cur));
        }
    }, undefined);
}    

var claim = () => {
    console.log("claim".padEnd(20, "="));
    var combinations = [
        [icici, secret, icici.atomicSwapInr().claim],
        [boa, secret, boa.atomicSwapUsd().claim]
    ];
    var processClaim = ([who, secret, claimFun]) => new Promise( (resolve, reject) => {
        who.web3.personal.unlockAccount(who.address, () => {
            var txHash = claimFun.sendTransaction(secret, {from: who.address, gas: 4712388, gasPrice: '0x00', gasLimit: '0x47b760'})
            waitForTx(txHash).catch(reject).then(resolve);
        });
    });
    return combinations.reduce((prev, cur) =>{
        if (!prev) {
            return processClaim(cur);
        } else {
            return prev.then(processClaim(cur));
        }
    }, undefined);
}    

distributeFundsAcross().then(deployContracts).then(tapInto).then(issueCurrency).then(approve).then(lock).then(claim).then(d => {
    console.log("========================");
    console.log("Bank.printUsdBalances();");
    Bank.printUsdBalances();
    console.log("Bank.printInrBalances();");
    Bank.printInrBalances();
});
