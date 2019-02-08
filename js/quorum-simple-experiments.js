var Web3 = require("web3");
var _ = require("lodash");

function Bank(abbreviation) {
    if (!Bank.reg) {
        Bank.reg = [];
    } 
    Bank[abbreviation] = this;
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

Bank.fundedAccount = (eth => _.maxBy(eth.accounts, eth.getBalance))(_.first(Bank.reg).web3.eth);
Bank.reg.forEach(bank => {
    bank.address = _.find( bank.web3.eth.accounts, account => account !== Bank.fundedAccount);
});
var solc = require("solc");
var code = `
contract USD {
    mapping (address => uint) public balances;
    address public owner;
    constructor() public {
        owner = msg.sender;
    }
    function issueUSD(address to, uint amount) public {
        if(msg.sender == owner) {
            balances[to] += amount;
        }
    }
    function getUSDBalance(address account) public view returns (uint balance)  {
        return balances[account];
    }
}`;

var compiled = solc.compile(code);
var compiledContract = compiled.contracts[':USD']

var abi = JSON.parse(compiledContract.interface);
var bytecode = '0x' + compiledContract.bytecode;

var deployerBank = Bank.reg[0];

deployerBank.web3.personal.unlockAccount(Bank.fundedAccount);
var opts = {
    from: Bank.fundedAccount,
    data: bytecode,
    gas: "4700000"
};

var deployed = deployerBank.web3.eth.contract(abi).new(opts);

if (Bank.fundedAccount == deployed.owner.call()) {
    console.log("owners match")
}

deployerBank.web3.personal.unlockAccount(Bank.fundedAccount);
Promise.all(Bank.reg.map(bank=>{
    return new Promise((resolve, reject)=>{
        deployed.issueUSD.sendTransaction( bank.address, 1000, {
            from: Bank.fundedAccount,
            data: bytecode,
            gas: "4700000"
        }, (e, result) =>{
            if (e) {
                reject(e);
            } else {
                resolve(result);
            }
        });
    });
})).then(data => {
    Bank.reg.map(bank=> {
        var balance = deployed.getUSDBalance.call(bank.address).toString();
        console.log(`${bank.description} balance: ${balance}`);
    });
});
///////////////////////////////more
var code = `
contract Debuggable {event Debug(string what);}
contract USD is Debuggable {
    mapping (address => uint) public balances;
    mapping (address => mapping (address => uint)) public allowed;
    address public owner;
    constructor() public {
        emit Debug("constructor() public {");
        owner = msg.sender;
    }
    function issueUSD(address to, uint amount) public {
        emit Debug(bytes32("function issueUSD"));
        if(msg.sender == owner) {
            emit Debug("if(msg.sender == owner)");
            balances[to] += amount;
            emit Debug("balances[to] += amount");
        }
    }
    function transferUSD(address to, uint amount) public {
        emit Debug("function transferUSD");
        if (balances[msg.sender] >= amount) {
            emit Debug("balances[msg.sender]>=amount?");
            balances[msg.sender] -= amount;
            emit Debug("balances[msg.sender] -= amount;");
            balances[to] += amount;
            emit Debug("balances[to] += amount;");
        }
    }
    function getUSDBalance(address account) public view returns (uint balance)  {
        return balances[account];
    }
    function approve(address spender, uint amount)  public {
        emit Debug("function approve(address spender, uint amount)  public {");
        allowed[spender][msg.sender] = amount;
        emit Debug("allowed[spender][msg.sender] = amount;");
    }
    function transferUSDFrom(address from, address to, uint amount) public {
        emit Debug("function transferUSDFrom(address from, address to, uint amount) public {");
        if(allowed[msg.sender][from] >= amount && balances[from] >= amount) {
            emit Debug("if(allowed[msg.sender][from] >= amount && balances[from] >= amount) {");
            allowed[msg.sender][from] -= amount;
            emit Debug("allowed[msg.sender][from] -= amount;");
            balances[from] -= amount;
            emit Debug("balances[from] -= amount;");
            balances[to] += amount;
            emit Debug("balances[to] += amount;");
        }
    }
}
contract AtomicSwap_USD is Debuggable {
    struct AtomicTxn {
        address from;
        address to;
        uint lockPeriod;
        uint amount;
    }
    mapping (bytes32 =>  AtomicTxn) public txns;
    USD USDContract;
    event usdLocked(address to, bytes32 hash, uint expiryTime, uint amount);
    event usdUnlocked(bytes32 hash);
    event usdClaimed(string secret, address from, bytes32 hash);
    constructor(address usdContractAddress) public {
        emit Debug("constructor(address usdContractAddress) public {");
        USDContract = USD(usdContractAddress);
        emit Debug("USDContract = USD(usdContractAddress);");
    }
    function lock(address to, bytes32 hash, uint lockExpiryMinutes, uint amount) public {
        emit Debug("function lock(address to, bytes32 hash, uint lockExpiryMinutes, uint amount) public {");
        USDContract.transferUSDFrom(msg.sender, address(this), amount);
        emit Debug("USDContract.transferUSDFrom(msg.sender, address(this), amount);");
        txns[hash] = AtomicTxn(msg.sender, to, block.timestamp + (lockExpiryMinutes * 60), amount);
        emit Debug("txns[hash] = AtomicTxn(msg.sender, to, block.timestamp + (lockExpiryMinutes * 60), amount);");
        emit usdLocked(to, hash, block.timestamp + (lockExpiryMinutes * 60), amount);
    }
    function unlock(bytes32 hash) public {
        emit Debug("function unlock(bytes32 hash) public {");
        if (txns[hash].lockPeriod < block.timestamp) {
            emit Debug("if (txns[hash].lockPeriod < block.timestamp) {");
            USDContract.transferUSD(txns[hash].from, txns[hash].amount);
            emit Debug("USDContract.transferUSD(txns[hash].from, txns[hash].amount);");
            emit usdUnlocked(hash);
        }
    }
    function claim(string memory secret) public {
        emit Debug("function claim(string memory secret) public {");
        bytes32 hash = sha256(bytes(secret));
        emit Debug("bytes32 hash = sha256(bytes(secret));");
        USDContract.transferUSD(txns[hash].to, txns[hash].amount);
        emit Debug("USDContract.transferUSD(txns[hash].to, txns[hash].amount);");
        emit usdClaimed(secret, txns[hash].from, hash);
    }
    function calculateHash(string memory secret) public pure returns (bytes32 result) {
        return sha256(bytes(secret));
    }
}`;

var compiled = solc.compile(code);
var compiledContract = compiled.contracts[':USD']

var abi = JSON.parse(compiledContract.interface);
var bytecode = '0x' + compiledContract.bytecode;

var deployerBank = Bank.reg[0];

deployerBank.web3.personal.unlockAccount(Bank.fundedAccount);

var r = _.range(100).map(n=>{
    var deployed = deployerBank.web3.eth.contract(abi).new({
        from: Bank.fundedAccount,
        data: bytecode,
        gas: "4700000"
    });
    return deployed;
}).map(d=>d.transactionHash)



Promise.all(_.range(0, 100).map(n => deployerBank.web3.eth.contract(abi).new({
    from: Bank.fundedAccount,
    data: bytecode,
    gas: "4700000"
}).transactionHash).map(waitForTx)).then(d => d.map(tr=>tr.contractAddress)).then(console.log);



waitForTx(deployed.transactionHash).then(console.log)

(txHash => _.every(Bank.reg, bank => (tx => tx && tx.blockNumber)(bank.web3.eth.getTransaction(txHash))))(deployed.transactionHash)

Bank.reg.map(b=>b.web3.eth.getTransaction(deployed.transactionHash).blockNumber);

var txs = b => b.web3s.map(web3 => (tx => tx && tx.blockNumber)(web3.eth.getTransaction(txHash)));


var waitForTx = ((banks, triesAttempted, waitMilliseconds) => txHash  => new Promise( (resolve, reject) => {        
    var tries = triesAttempted;
    var tried = 0;
    var waitForAddress = () => setTimeout( () => {
        if (_.every(banks, bank => (tx => tx && tx.blockNumber)(bank.web3.eth.getTransaction(txHash)))) {
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
}))(Bank.reg, 10, 2000);



if (Bank.fundedAccount == deployed.owner.call()) {
    console.log("owners match");
} else {
    console.log("owners don't match");
}

var waitForTx = ((banks, triesAttempted, waitMilliseconds) => txHash  => new Promise( (resolve, reject) => {        
    var tries = triesAttempted;
    var tried = 0;
    var waitForAddress = () => setTimeout( () => {
        if (_.every(banks, bank => (tx => tx && tx.blockNumber)(bank.web3.eth.getTransaction(txHash)))) {
            return resolve(banks.getTransactionReceipt(txHash));
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
}))(Bank.reg, 10, 2000);




var waitForContract = contract  => {
    return new Promise( (resolve, reject) => {        
        var tries = 10;
        var tried = 0;
        var waitMiliseconds = 2000;
        var waitForAddress = () => setTimeout( () => {
            var txRec = contract._eth.getTransactionReceipt(contract.transactionHash);
            if (txRec && txRec.contractAddress) {
                return resolve(txRec.contractAddress);
            } else {
                tries -= 1;
                tried += 1;
                console.log(`tried ${(waitMiliseconds * tried)/1000} seconds`);
                if (tries === 0) {
                    return reject("timeout");
                } else {
                    return waitForAddress();
                }
            }
        }, waitMiliseconds);
        return waitForAddress();
    });
}

var waitForTx = ((banks, triesAttempted, waitMilliseconds) => txHash  => new Promise( (resolve, reject) => {        
    var tries = triesAttempted;
    var tried = 0;
    var waitForAddress = () => setTimeout( () => {
        if (_.every(banks, bank => (tx => tx && tx.blockNumber)(bank.web3.eth.getTransaction(txHash)))) {
            console.log("=======================");
            console.log(banks[0]);
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
}))(Bank.reg, 10, 2000);

var waitForContract = contract => waitForTx(contract.transactionHash).then(txRec => txRec.contractAddress);

deployerBank.web3.personal.unlockAccount(Bank.fundedAccount);
Promise.all(Bank.reg.map(bank=>{
    return new Promise((resolve, reject)=>{
        deployed.issueUSD.sendTransaction( bank.address, 1000, {
            from: Bank.fundedAccount,
            data: bytecode,
            gas: "4700000"
        }, (e, result) =>{
            if (e) {
                reject(e);
            } else {
                resolve(result);
            }
        });
    }).then(d => {
        console.log(d);
        return waitForTx(d);
    });
})).then(data => {
    console.log(data);
    // Bank.reg.map(bank=> {
    //     var balance = deployed.getUSDBalance.call(bank.address).toString();
    //     console.log(`${bank.description} balance: ${balance}`);
    // });
});


//AtomicSwap_USD