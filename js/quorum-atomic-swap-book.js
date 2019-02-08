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
            return Bank.reg[0][cur]()[`get${cur.toUpperCase()}Balance`].call(key);
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
}))(["usd", "inr"]);


var solc = require("solc");
//var code = "pragma solidity ^0.4.19; contract INR { mapping (address => uint) balances; mapping (address => mapping (address => uint)) allowed; address owner; constructor() public { owner = msg.sender; } function issueINR(address to, uint amount) public { if(msg.sender == owner) { balances[to] += amount; } } function transferINR(address to, uint amount) public { if (balances[msg.sender] >= amount) { balances[msg.sender] -= amount; balances[to] += amount; } } function getINRBalance(address account) public view returns (uint balance) { return balances[account]; } function approve(address spender, uint amount) public { allowed[spender][msg.sender] = amount; } function transferINRFrom(address from, address to, uint amount) public { if(allowed[msg.sender][from] >= amount && balances[from] >= amount) { allowed[msg.sender][from] -= amount; balances[from] -= amount; balances[to] += amount; } } } contract AtomicSwap_INR { struct AtomicTxn { address from; address to; uint lockPeriod; uint amount; } mapping (bytes32 => AtomicTxn) txns; INR INRContract; event inrLocked(address to, bytes32 hash, uint expiryTime, uint amount); event inrUnlocked(bytes32 hash); event inrClaimed(string secret, address from, bytes32 hash); constructor(address inrContractAddress) public { INRContract = INR(inrContractAddress); } function lock(address to, bytes32 hash, uint lockExpiryMinutes, uint amount) public { INRContract.transferINRFrom(msg.sender, address(this), amount); txns[hash] = AtomicTxn(msg.sender, to, block.timestamp + (lockExpiryMinutes * 60), amount); emit inrLocked(to, hash, block.timestamp + (lockExpiryMinutes * 60), amount); } function unlock(bytes32 hash) public { if (txns[hash].lockPeriod < block.timestamp) { INRContract.transferINR(txns[hash].from, txns[hash].amount); emit inrUnlocked(hash); } } function claim(string secret) public { bytes32 hash = sha256(secret); INRContract.transferINR(txns[hash].to, txns[hash].amount); emit inrClaimed(secret, txns[hash].from, hash); } function calculateHash(string secret) public pure returns (bytes32 result) { return sha256(secret); } } contract USD { mapping (address => uint) balances; mapping (address => mapping (address => uint)) allowed; address owner; constructor() public { owner = msg.sender; } function issueUSD(address to, uint amount) public { if(msg.sender == owner) { balances[to] += amount; } } function transferUSD(address to, uint amount) public { if (balances[msg.sender] >= amount) { balances[msg.sender] -= amount; balances[to] += amount; } } function getUSDBalance(address account) public view returns (uint balance) { return balances[account]; } function approve(address spender, uint amount) public { allowed[spender][msg.sender] = amount; } function transferUSDFrom(address from, address to, uint amount) public { if(allowed[msg.sender][from] >= amount && balances[from] >= amount) { allowed[msg.sender][from] -= amount; balances[from] -= amount; balances[to] += amount; } } } contract AtomicSwap_USD { struct AtomicTxn { address from; address to; uint lockPeriod; uint amount; } mapping (bytes32 => AtomicTxn) txns; USD USDContract; event usdLocked(address to, bytes32 hash, uint expiryTime, uint amount); event usdUnlocked(bytes32 hash); event usdClaimed(string secret, address from, bytes32 hash); constructor(address usdContractAddress) public { USDContract = USD(usdContractAddress); } function lock(address to, bytes32 hash, uint lockExpiryMinutes, uint amount) public { USDContract.transferUSDFrom(msg.sender, address(this), amount); txns[hash] = AtomicTxn(msg.sender, to, block.timestamp + (lockExpiryMinutes * 60), amount); emit usdLocked(to, hash, block.timestamp + (lockExpiryMinutes * 60), amount); } function unlock(bytes32 hash) public { if (txns[hash].lockPeriod < block.timestamp) { USDContract.transferUSD(txns[hash].from, txns[hash].amount); emit usdUnlocked(hash); } } function claim(string secret) public { bytes32 hash = sha256(secret); USDContract.transferUSD(txns[hash].to, txns[hash].amount); emit usdClaimed(secret, txns[hash].from, hash); } function calculateHash(string secret) public pure returns (bytes32 result) { return sha256(secret); } }";
//with logs below:
//var code = 'pragma solidity ^0.4.19;contract Debuggable { event Debug(string what);}contract INR is Debuggable { mapping (address => uint) balances; mapping (address => mapping (address => uint)) allowed; address owner; constructor() public { emit Debug("constructor() public {"); owner = msg.sender; emit Debug("owner = msg.sender;"); } function issueINR(address to, uint amount) public { emit Debug("function issueINR(address to, uint amount) public {"); if(msg.sender == owner) { emit Debug("if(msg.sender == owner) {"); balances[to] += amount; emit Debug("balances[to] += amount;"); } } function transferINR(address to, uint amount) public { emit Debug("function transferINR(address to, uint amount) public {"); if (balances[msg.sender] >= amount) { emit Debug("if (balances[msg.sender] >= amount) {"); balances[msg.sender] -= amount; emit Debug("balances[msg.sender] -= amount;"); balances[to] += amount; emit Debug("balances[to] += amount;"); } } function getINRBalance(address account) public view returns (uint balance) { return balances[account]; } function approve(address spender, uint amount) public { emit Debug("function approve(address spender, uint amount) public {"); allowed[spender][msg.sender] = amount; emit Debug("allowed[spender][msg.sender] = amount;"); } function transferINRFrom(address from, address to, uint amount) public { emit Debug("function transferINRFrom(address from, address to, uint amount) public {"); if(allowed[msg.sender][from] >= amount && balances[from] >= amount) { emit Debug("if(allowed[msg.sender][from] >= amount && balances[from] >= amount) {"); allowed[msg.sender][from] -= amount; emit Debug("allowed[msg.sender][from] -= amount;"); balances[from] -= amount; emit Debug("balances[from] -= amount;"); balances[to] += amount; emit Debug("balances[to] += amount;"); } }}contract AtomicSwap_INR is Debuggable { struct AtomicTxn { address from; address to; uint lockPeriod; uint amount; } mapping (bytes32 => AtomicTxn) txns; INR INRContract; event inrLocked(address to, bytes32 hash, uint expiryTime, uint amount); event inrUnlocked(bytes32 hash); event inrClaimed(string secret, address from, bytes32 hash); constructor(address inrContractAddress) public { emit Debug("constructor(address inrContractAddress) public {"); INRContract = INR(inrContractAddress); emit Debug("INRContract = INR(inrContractAddress);"); } function lock(address to, bytes32 hash, uint lockExpiryMinutes, uint amount) public { emit Debug("function lock(address to, bytes32 hash, uint lockExpiryMinutes, uint amount) public {"); INRContract.transferINRFrom(msg.sender, address(this), amount); emit Debug("INRContract.transferINRFrom(msg.sender, address(this), amount);"); txns[hash] = AtomicTxn(msg.sender, to, block.timestamp + (lockExpiryMinutes * 60), amount); emit Debug("txns[hash] = AtomicTxn(msg.sender, to, block.timestamp + (lockExpiryMinutes * 60), amount);"); emit inrLocked(to, hash, block.timestamp + (lockExpiryMinutes * 60), amount); } function unlock(bytes32 hash) public { emit Debug("function unlock(bytes32 hash) public {"); if (txns[hash].lockPeriod < block.timestamp) { emit Debug("if (txns[hash].lockPeriod < block.timestamp) {"); INRContract.transferINR(txns[hash].from, txns[hash].amount); emit Debug("INRContract.transferINR(txns[hash].from, txns[hash].amount);"); emit inrUnlocked(hash); } } function claim(string memory secret) public { emit Debug("function claim(string memory secret) public {"); bytes32 hash = sha256(bytes(secret)); emit Debug("bytes32 hash = sha256(bytes(secret));"); INRContract.transferINR(txns[hash].to, txns[hash].amount); emit Debug("INRContract.transferINR(txns[hash].to, txns[hash].amount);"); emit inrClaimed(secret, txns[hash].from, hash); } function calculateHash(string memory secret) public pure returns (bytes32 result) { return sha256(bytes(secret)); }}contract USD is Debuggable { mapping (address => uint) balances; mapping (address => mapping (address => uint)) allowed; address owner; constructor() public { emit Debug("constructor() public {"); owner = msg.sender; } function issueUSD(address to, uint amount) public { emit Debug("function issueUSD(address to, uint amount) public {"); if(msg.sender == owner) { emit Debug("if(msg.sender == owner) {"); balances[to] += amount; emit Debug("balances[to] += amount;"); } } function transferUSD(address to, uint amount) public { emit Debug("function transferUSD(address to, uint amount) public {"); if (balances[msg.sender] >= amount) { emit Debug("if (balances[msg.sender] >= amount) {"); balances[msg.sender] -= amount; emit Debug("balances[msg.sender] -= amount;"); balances[to] += amount; emit Debug("balances[to] += amount;"); } } function getUSDBalance(address account) public view returns (uint balance) { return balances[account]; } function approve(address spender, uint amount) public { emit Debug("function approve(address spender, uint amount) public {"); allowed[spender][msg.sender] = amount; emit Debug("allowed[spender][msg.sender] = amount;"); } function transferUSDFrom(address from, address to, uint amount) public { emit Debug("function transferUSDFrom(address from, address to, uint amount) public {"); if(allowed[msg.sender][from] >= amount && balances[from] >= amount) { emit Debug("if(allowed[msg.sender][from] >= amount && balances[from] >= amount) {"); allowed[msg.sender][from] -= amount; emit Debug("allowed[msg.sender][from] -= amount;"); balances[from] -= amount; emit Debug("balances[from] -= amount;"); balances[to] += amount; emit Debug("balances[to] += amount;"); } }}contract AtomicSwap_USD is Debuggable { struct AtomicTxn { address from; address to; uint lockPeriod; uint amount; } mapping (bytes32 => AtomicTxn) txns; USD USDContract; event usdLocked(address to, bytes32 hash, uint expiryTime, uint amount); event usdUnlocked(bytes32 hash); event usdClaimed(string secret, address from, bytes32 hash); constructor(address usdContractAddress) public { emit Debug("constructor(address usdContractAddress) public {"); USDContract = USD(usdContractAddress); emit Debug("USDContract = USD(usdContractAddress);"); } function lock(address to, bytes32 hash, uint lockExpiryMinutes, uint amount) public { emit Debug("function lock(address to, bytes32 hash, uint lockExpiryMinutes, uint amount) public {"); USDContract.transferUSDFrom(msg.sender, address(this), amount); emit Debug("USDContract.transferUSDFrom(msg.sender, address(this), amount);"); txns[hash] = AtomicTxn(msg.sender, to, block.timestamp + (lockExpiryMinutes * 60), amount); emit Debug("txns[hash] = AtomicTxn(msg.sender, to, block.timestamp + (lockExpiryMinutes * 60), amount);"); emit usdLocked(to, hash, block.timestamp + (lockExpiryMinutes * 60), amount); } function unlock(bytes32 hash) public { emit Debug("function unlock(bytes32 hash) public {"); if (txns[hash].lockPeriod < block.timestamp) { emit Debug("if (txns[hash].lockPeriod < block.timestamp) {"); USDContract.transferUSD(txns[hash].from, txns[hash].amount); emit Debug("USDContract.transferUSD(txns[hash].from, txns[hash].amount);"); emit usdUnlocked(hash); } } function claim(string memory secret) public { emit Debug("function claim(string memory secret) public {"); bytes32 hash = sha256(bytes(secret)); emit Debug("bytes32 hash = sha256(bytes(secret));"); USDContract.transferUSD(txns[hash].to, txns[hash].amount); emit Debug("USDContract.transferUSD(txns[hash].to, txns[hash].amount);"); emit usdClaimed(secret, txns[hash].from, hash); } function calculateHash(string memory secret) public pure returns (bytes32 result) { return sha256(bytes(secret)); }}';
var code = `pragma solidity ^0.4.19;contract Debuggable { event Debug(string what);}
contract INR is Debuggable { mapping (address => uint) public balances; mapping (address => mapping (address => uint)) public allowed; address public owner; constructor() public { emit Debug("constructor() public {"); owner = msg.sender; emit Debug("owner = msg.sender;"); } function issueINR(address to, uint amount) public { emit Debug("function issueINR(address to, uint amount) public {"); if(msg.sender == owner) { emit Debug("if(msg.sender == owner) {"); balances[to] += amount; emit Debug("balances[to] += amount;"); } } function transferINR(address to, uint amount) public { emit Debug("function transferINR(address to, uint amount) public {"); if (balances[msg.sender] >= amount) { emit Debug("if (balances[msg.sender] >= amount) {"); balances[msg.sender] -= amount; emit Debug("balances[msg.sender] -= amount;"); balances[to] += amount; emit Debug("balances[to] += amount;"); } } function getINRBalance(address account) public view returns (uint balance) { return balances[account]; } function approve(address spender, uint amount) public { emit Debug("function approve(address spender, uint amount) public {"); allowed[spender][msg.sender] = amount; emit Debug("allowed[spender][msg.sender] = amount;"); } function transferINRFrom(address from, address to, uint amount) public { emit Debug("function transferINRFrom(address from, address to, uint amount) public {"); if(allowed[msg.sender][from] >= amount && balances[from] >= amount) { emit Debug("if(allowed[msg.sender][from] >= amount && balances[from] >= amount) {"); allowed[msg.sender][from] -= amount; emit Debug("allowed[msg.sender][from] -= amount;"); balances[from] -= amount; emit Debug("balances[from] -= amount;"); balances[to] += amount; emit Debug("balances[to] += amount;"); } }}
contract AtomicSwap_INR is Debuggable { struct AtomicTxn { address from; address to; uint lockPeriod; uint amount; } mapping (bytes32 => AtomicTxn) public txns; INR INRContract; event inrLocked(address to, bytes32 hash, uint expiryTime, uint amount); event inrUnlocked(bytes32 hash); event inrClaimed(string secret, address from, bytes32 hash); constructor(address inrContractAddress) public { emit Debug("constructor(address inrContractAddress) public {"); INRContract = INR(inrContractAddress); emit Debug("INRContract = INR(inrContractAddress);"); } function lock(address to, bytes32 hash, uint lockExpiryMinutes, uint amount) public { emit Debug("function lock()"); INRContract.transferINRFrom(msg.sender, address(this), amount); emit Debug("INRContract.transferINRFrom();"); txns[hash] = AtomicTxn(msg.sender, to, block.timestamp + (lockExpiryMinutes * 60), amount); emit Debug("txns[hash] = AtomicTxn()"); emit inrLocked(to, hash, block.timestamp + (lockExpiryMinutes * 60), amount); } function unlock(bytes32 hash) public { emit Debug("function unlock(bytes32 hash) public {"); if (txns[hash].lockPeriod < block.timestamp) { emit Debug("if (txns[hash].lockPeriod < block.timestamp) {"); INRContract.transferINR(txns[hash].from, txns[hash].amount); emit Debug("INRContract.transferINR()"); emit inrUnlocked(hash); } } function claim(string memory secret) public { emit Debug("function claim(string memory secret) public {"); bytes32 hash = sha3(bytes(secret)); emit Debug("bytes32 hash = sha3(bytes(secret));"); INRContract.transferINR(txns[hash].to, txns[hash].amount); emit Debug("INRContract.transferINR(txns[hash].to, txns[hash].amount);"); emit inrClaimed(secret, txns[hash].from, hash); } function calculateHash(string memory secret) public pure returns (bytes32 result) { return sha3(bytes(secret)); }}
contract AtomicSwap is Debuggable { 
    struct AtomicTxn { 
        address from; 
        address to; 
        uint lockPeriod; 
        uint amount; } 
    mapping (bytes32 => AtomicTxn) public txns;  
    event lockCall(address to, bytes32 hash, uint lockExpiryMinutes, uint amount);
    event usdLocked(address to, bytes32 hash, uint expiryTime, uint amount); 
    event usdUnlocked(bytes32 hash); 
    event usdClaimed(string secret, address from, bytes32 hash); 
    event UintPass(uint uintInQuestion);
    // constructor(address usdContractAddress) public { 
    //     emit Debug("constructor(address usdContractAddress) public {"); 
    //     USDContract = USD(usdContractAddress);
    //     USDContract.merp(); 
    //     emit Debug("USDContract = USD(usdContractAddress);"); } 
    function lock30(address to, bytes32 hash, uint amount) public { 
        //emit UintPass(amount);
        //uint lockExpiryMinutes = 30;
        //emit lockCall(to, hash, lockExpiryMinutes, amount);
        USDContract.merp.gas(1000)();
        //USDContract.transferUSDFrom.gas(1000)(msg.sender, address(this), amount); 
        //txns[hash] = AtomicTxn(msg.sender, to, block.timestamp + (lockExpiryMinutes * 60), amount); 
        //emit usdLocked(to, hash, block.timestamp + (lockExpiryMinutes * 60), amount); 
    }
    function claim(string memory secret) public { 
        emit Debug("function claim(str..."); 
        bytes32 hash = sha3(bytes(secret)); 
        emit Debug("bytes32 hash = sha2"); 
        USDContract.transferUSD(txns[hash].to, txns[hash].amount); 
        emit Debug("USDContract.transferUS"); 
        emit usdClaimed(secret, txns[hash].from, hash); } 
        function calculateHash(string memory secret) public returns (bytes32) { 
              return sha3(bytes(secret)); }}
contract USD is AtomicSwap { 
    mapping (address => uint) public balances; 
    mapping (address => mapping (address => uint)) public allowed; 
    address public owner; 
    address[] public addressesUsed;
    event issueUSDCall(address to, uint amount);
    event transferUSDCall(address to, uint amount);
    event transferUSDFromCall(address from, address to, uint amount);
    event approveCall(address spender, uint amount);
    event tick(string message);
    constructor() public { emit Debug("constructor() public {"); owner = msg.sender; } 
    function issueUSD(address to, uint amount) public { 
        emit issueUSDCall(to, amount); 
        emit Debug("function issueUSD()"); 
        if(msg.sender == owner) { 
            emit Debug("if(msg.sender == owner)"); 
            balances[to] += amount; 
            emit Debug("balances[to] += amount;"); 
        } 
    } 
    function transferUSD(address to, uint amount) public { emit transferUSDCall(to, amount); emit Debug("function transferUSD(address to, uint amount) public {"); addressesUsed.push(to); if (balances[msg.sender] >= amount) { emit Debug("if (balances[msg.sender] >= amount) {"); balances[msg.sender] -= amount; emit Debug("balances[msg.sender] -= amount;"); balances[to] += amount; emit Debug("balances[to] += amount;"); } } 
    function getUSDBalance(address account) public view returns (uint) { return balances[account]; } 
    function approve(address spender, uint amount) public { 
        emit approveCall(spender, amount);
        emit Debug("function approve(address spender, uint amount) public {"); 
        addressesUsed.push(spender); 
        allowed[spender][msg.sender] = amount; 
        emit Debug("allowed[spender][msg.sender] = amount;"); } 
    function merp() public {
        emit tick("ok");     
    }
    function transferUSDFrom(address from, address to, uint amount) public { 
        emit tick("ok");     
        emit Debug("ok");     
    }}
    // function transferUSDFrom(address from, address to, uint amount) public { 
    //     emit transferUSDFromCall(from, to, amount); 
    //     emit Debug("function transferUSDFrom("); 
    //     if(allowed[msg.sender][from] >= amount && balances[from] >= amount) { 
    //         emit Debug("if(allowed>=amount&&bal>=amount)"); 
    //         allowed[msg.sender][from] -= amount; 
    //         emit Debug("allowed -= amount;"); 
    //         balances[from] -= amount; 
    //         emit Debug("balances -= amount;"); 
    //         balances[to] += amount; 
    //         emit Debug("balances[to] += amount;"); } }}
`;

//var code = `pragma solidity ^0.5.3; contract USD {} contract AtomicSwap_USD {}`;
// var code = `//pragma solidity ^0.5.0;contract Debuggable { event Debug(string what);}
// //contract INR is Debuggable { mapping (address => uint) public balances; mapping (address => mapping (address => uint)) public allowed; address public owner; constructor() public { emit Debug("constructor() public {"); owner = msg.sender; emit Debug("owner = msg.sender;"); } function issueINR(address to, uint amount) public { emit Debug("function issueINR(address to, uint amount) public {"); if(msg.sender == owner) { emit Debug("if(msg.sender == owner) {"); balances[to] += amount; emit Debug("balances[to] += amount;"); } } function transferINR(address to, uint amount) public { emit Debug("function transferINR(address to, uint amount) public {"); if (balances[msg.sender] >= amount) { emit Debug("if (balances[msg.sender] >= amount) {"); balances[msg.sender] -= amount; emit Debug("balances[msg.sender] -= amount;"); balances[to] += amount; emit Debug("balances[to] += amount;"); } } function getINRBalance(address account) public view returns (uint balance) { return balances[account]; } function approve(address spender, uint amount) public { emit Debug("function approve(address spender, uint amount) public {"); allowed[spender][msg.sender] = amount; emit Debug("allowed[spender][msg.sender] = amount;"); } function transferINRFrom(address from, address to, uint amount) public { emit Debug("function transferINRFrom(address from, address to, uint amount) public {"); if(allowed[msg.sender][from] >= amount && balances[from] >= amount) { emit Debug("if(allowed[msg.sender][from] >= amount && balances[from] >= amount) {"); allowed[msg.sender][from] -= amount; emit Debug("allowed[msg.sender][from] -= amount;"); balances[from] -= amount; emit Debug("balances[from] -= amount;"); balances[to] += amount; emit Debug("balances[to] += amount;"); } }}
// //contract AtomicSwap_INR is Debuggable { struct AtomicTxn { address from; address to; uint lockPeriod; uint amount; } mapping (bytes32 => AtomicTxn) public txns; INR INRContract; event inrLocked(address to, bytes32 hash, uint expiryTime, uint amount); event inrUnlocked(bytes32 hash); event inrClaimed(string secret, address from, bytes32 hash); constructor(address inrContractAddress) public { emit Debug("constructor(address inrContractAddress) public {"); INRContract = INR(inrContractAddress); emit Debug("INRContract = INR(inrContractAddress);"); } function lock(address to, bytes32 hash, uint lockExpiryMinutes, uint amount) public { emit Debug("function lock()"); INRContract.transferINRFrom(msg.sender, address(this), amount); emit Debug("INRContract.transferINRFrom();"); txns[hash] = AtomicTxn(msg.sender, to, block.timestamp + (lockExpiryMinutes * 60), amount); emit Debug("txns[hash] = AtomicTxn()"); emit inrLocked(to, hash, block.timestamp + (lockExpiryMinutes * 60), amount); } function unlock(bytes32 hash) public { emit Debug("function unlock(bytes32 hash) public {"); if (txns[hash].lockPeriod < block.timestamp) { emit Debug("if (txns[hash].lockPeriod < block.timestamp) {"); INRContract.transferINR(txns[hash].from, txns[hash].amount); emit Debug("INRContract.transferINR()"); emit inrUnlocked(hash); } } function claim(string memory secret) public { emit Debug("function claim(string memory secret) public {"); bytes32 hash = keccak256(bytes(secret)); emit Debug("bytes32 hash = sha3(bytes(secret));"); INRContract.transferINR(txns[hash].to, txns[hash].amount); emit Debug("INRContract.transferINR(txns[hash].to, txns[hash].amount);"); emit inrClaimed(secret, txns[hash].from, hash); } function calculateHash(string memory secret) public pure returns (bytes32 result) { return keccak256(bytes(secret)); }}
// contract USD { 
//     // mapping (address => uint) public balances; 
//     // mapping (address => mapping (address => uint)) public allowed; 
//     // address public owner; 
//     // address[] public addressesUsed;
//     // event issueUSDCall(address to, uint amount);
//     // event transferUSDCall(address to, uint amount);
//     // event transferUSDFromCall(address from, address to, uint amount);
//     // event approveCall(address spender, uint amount);
//     // event tick(string message);
//     // constructor() public { emit Debug("constructor() public {"); owner = msg.sender; } 
//     // function issueUSD(address to, uint amount) public { 
//     //     emit issueUSDCall(to, amount); 
//     //     emit Debug("function issueUSD()"); 
//     //     if(msg.sender == owner) { 
//     //         emit Debug("if(msg.sender == owner)"); 
//     //         balances[to] += amount; 
//     //         emit Debug("balances[to] += amount;"); 
//     //     } 
//     // } 
//     // function transferUSD(address to, uint amount) public { emit transferUSDCall(to, amount); emit Debug("function transferUSD(address to, uint amount) public {"); addressesUsed.push(to); if (balances[msg.sender] >= amount) { emit Debug("if (balances[msg.sender] >= amount) {"); balances[msg.sender] -= amount; emit Debug("balances[msg.sender] -= amount;"); balances[to] += amount; emit Debug("balances[to] += amount;"); } } 
//     // function getUSDBalance(address account) public view returns (uint) { return balances[account]; } 
//     // function approve(address spender, uint amount) public { 
//     //     emit approveCall(spender, amount);
//     //     emit Debug("function approve(address spender, uint amount) public {"); 
//     //     addressesUsed.push(spender); 
//     //     allowed[spender][msg.sender] = amount; 
//     //     emit Debug("allowed[spender][msg.sender] = amount;"); } 
//     function merp() public {
//         //emit tick("ok");     
//     }
//     // function transferUSDFrom(address from, address to, uint amount) public { 
//     //     //emit tick("ok");     
//     //     //emit Debug("ok");     
//     // }
// }
// contract AtomicSwap_USD { 
//     // struct AtomicTxn { 
//     //     address from; 
//     //     address to; 
//     //     uint lockPeriod; 
//     //     uint amount; } 
//     // mapping (bytes32 => AtomicTxn) public txns; 
//     USD USDContract; 
//     // event lockCall(address to, bytes32 hash, uint lockExpiryMinutes, uint amount);
//     // event usdLocked(address to, bytes32 hash, uint expiryTime, uint amount); 
//     // event usdUnlocked(bytes32 hash); 
//     // event usdClaimed(string secret, address from, bytes32 hash); 
//     // event UintPass(uint uintInQuestion);
//     constructor(address usdContractAddress) public { 
//         //emit Debug("constructor(address usdContractAddress) public {"); 
//         USDContract = USD(usdContractAddress);
//         //USDContract = new USD();
//         USDContract.merp(); 
//         //emit Debug("USDContract = USD(usdContractAddress);"); 
//     } 
//     // function lock30(address to, bytes32 hash, uint amount) public { 
//     //     USDContract.merp.gas(1000)();
//     // }
//     function calculateHash(string memory secret) public returns (bytes32) { 
//             return keccak256(bytes(secret)); }
// }`;
// var code = `pragma solidity ^0.5.3;
// contract USD { 
//     event tick(string message);
//     function merp() public {
//         emit tick("ok");     
//     }
//     function() external {}
// }
// contract AtomicSwap_USD { 
//     USD USDContract; 
//     event tick(string message);
//     constructor(address usdContractAddress) public { 
//         USDContract = USD(usdContractAddress); 
//         emit tick("ok");    
//     }
//     function merp() public {
//         emit tick("merp strt");    
//         USDContract.merp.gas(1000)();
//         emit tick("merp end");    
//     }     
//     function() external {}
// }`;

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
//????
//var getNode = addressToFind => _.find(nodes, node => node.web3.eth.accounts.filter(account => account === addressToFind).length !== 0);

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
        console.log(bytecode);
        return new Promise(function(resolve, reject) {
            deployerBank.web3.personal.unlockAccount(deployerBank.address, function() {
                var from = deployerBank.address; 
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
})))([/*["INR", "rbi"],*/ ["USD", "frs"]])(Bank, compiled.contracts['all.sol']);

var issue = (regulator, recipient, issueMethod) => new Promise((resolve, reject) => {
    var process = (e, txnHash) => e ? reject(e) : resolve(txnHash);
    regulator.web3.personal.unlockAccount(regulator.address, () => {
        issueMethod.sendTransaction(recipient.address, 1000, {from: regulator.address, gasPrice: '0x00', gasLimit: '0x47b760'}, process);
    });
});

var issueCurrency = () => Promise.all([[frs, boa, frs.usd().issueUSD], 
                               [rbi, icici, rbi.inr().issueINR]].map(([regulator, recipient, issueMethod]) => new Promise((resolve, reject) => {
    var process = (e, txnHash) => e ? reject(e) : resolve(txnHash);
    regulator.web3.personal.unlockAccount(regulator.address, () => {
        issueMethod.sendTransaction(recipient.address, 1000, {from: regulator.address, gasPrice: '0x00', gasLimit: '0x47b760'}, process);
    });
}))).then(waitForTx);

var approve = () => Promise.all([[frs, boa, frs.atomicSwapUsd(), boa.usd().approve], 
                                 [rbi, icici, rbi.atomicSwapInr(), icici.inr().approve]].map(([regulator, approver, swapContract, approveMethod]) => new Promise((resolve, reject) => {
    var process = (e, txnHash) => e ? reject(e) : resolve(txnHash);
    approver.web3.personal.unlockAccount(approver.address);
    approveMethod.sendTransaction(swapContract.address, 1000, {from: approver.address, gasPrice: '0x00', gasLimit: '0x47b760'}, process);
}).then(txhash => waitForTx(txhash))));

var {frs, boa, icici, rbi} = Bank;
var secret = generateSecret();
//var hash;
// Bank.printUsdBalances();
// Bank.printInrBalances();
//hash = boa.atomicSwapUsd().calculateHash.call(secret, {from: boa.address});

var lock = ((secret/*, minutes*/, value, gas) => (transactingBank, sourceBank) => () => new Promise( (resolve, reject) => {
    transactingBank.web3.personal.unlockAccount(transactingBank.address, () => {
        var hash = transactingBank.atomicSwapUsd().calculateHash.call(secret, {from: transactingBank.address});
        var opts = {from: transactingBank.address, gas, gasPrice: '0x00', gasLimit: '0x47b760'};
        //var process = (e, txnHash) => e ? reject(e) : resolve(txnHash);
        transactingBank.web3.personal.unlockAccount(transactingBank.address, () => {
            transactingBank.atomicSwapUsd().lock30.sendTransaction(sourceBank.address, hash/*, minutes*/, value, opts, (e, txHash) => {
                waitForTx(txHash).then(resolve).catch(reject);
            });
        });
    });
}).then())(secret/*, 30*/, 1000, 4712388);

//var p = distributeFundsAcross().
deployContracts()//.then(issueCurrency).then(approve)
.then(d => new Promise( (resolve, reject) => {
    var opts = {from: boa.address, gas: 4712388, gasPrice: '0x00', gasLimit: '0x47b760'};
    var process = (e, txnHash) => e ? reject(e) : resolve(txnHash);
    boa.web3.personal.unlockAccount(boa.address, () => {
        //boa.atomicSwapUsd().calculateHash.sendTransaction(secret, {from: boa.address, gas: 4712388, gasPrice: '0x00', gasLimit: '0x47b760'})
        var swap = boa.atomicSwapUsd();
        //var hash = swap.calculateHash.call(secret, {from: boa.address, gas: 4712388, gasPrice: '0x00', gasLimit: '0x47b760'});
        //0x859eedc2f38ce
        //9c990aed
        //"00000000000000000000000000000000000000000000000000000000000003e8d37336a8b5631913bbc66ebc68161011ae79e3915dfddc568f5e4ad5681e519c00000000000000000000000087ed145761f0b0417f62c7e2e1e384ca4f9197d2"
        var o = opts; 
        swap.merp.sendTransaction(opts, process);
        //swap.lock30.sendTransaction(1000, hash, boa.address, opts, process);
    });                           
                       //}).then(d => {
                       //    return lock(boa, icici)
}))
//.then(lock(boa, icici))
.then(d => {
    console.log("atomicSwapUsd".padEnd(20, "="));
    var event = boa.atomicSwapUsd().allEvents({fromBlock:0, toBlock:"latest"});
    var d = event.watch(function (err, result) {
        if (err) {console.log(err);}
        console.log(`${result.event} ${JSON.stringify(result.args)}`)
    });
    console.log("usd".padEnd(20, "="));
    var event1 = boa.usd().allEvents({fromBlock:0, toBlock:"latest"});
    var d1 = event1.watch(function (err, result) {
        if (err) {console.log(err);}
        console.log(`${result.event} ${JSON.stringify(result.args)}`)
    });
});

                       //});

                       // .then(data => {
//     var msg = "USD Atomic Exchange Smart Contracts holds : ";
//     var usdBalance = boa.usd().getUSDBalance;
//     var addressToCheck = boa.atomicSwapUsd().address;
//     console.log(`${msg}${usdBalance.call(addressToCheck).toString()}`);
//     console.log(`${msg}${boa.usd().balances.call(addressToCheck).toString()}`);
//     //boa.atomicSwapUsd().txns.call()
//     var event = boa.atomicSwapUsd().allEvents({fromBlock:0, toBlock:"latest"});
//     var d = event.watch(function (err, result) {
//         if (err) {console.log(err);}
//         console.log(`${result.event} ${JSON.stringify(result.args)}`)
//     });
//     var event1 = boa.usd().allEvents({fromBlock:0, toBlock:"latest"});
//     var d1 = event1.watch(function (err, result) {
//         if (err) {console.log(err);}
//         console.log(`${result.event} ${JSON.stringify(result.args)}`)
//     });
// });



// Bank.reg.map(b=>[b.abbreviation,b.address])
// // 0x2ad225137688317b4e57f017114a11253b389f0d
// var event = boa.atomicSwapUsd().allEvents({fromBlock:0, toBlock:"latest"});
// var d = event.watch(function (err, result) {
//     if (err) {console.log(err);}
//     console.log(result.args);
// });
// Object.keys(boa.atomicSwapUsd());
// Object.keys(boa.usd());
// var n = 0;
// while (true) {
//     var address = boa.usd().addressesUsed.call(n);
//     if ('0x' === address) { break; }
//     console.log(address);
//     n += 1;
// }
// var bn = boa.usd().getUSDBalance.call('0xdf85292658a69ade0b271d082234760474f98b6d')
// console.log(`${boa.inr().getINRBalance.call('0x87ed145761f0b0417f62c7e2e1e384ca4f9197d2').toString()}`);
//  console.log(`${msg}${boa.usd().getUSDBalance.call('0xdf85292658a69ade0b271d082234760474f98b6d').toString()}`);
// boa.usd().allowed.call('0xdf85292658a69ade0b271d082234760474f98b6d')
// boa.atomicSwapUsd().abi.map(o=>o.name);
// boa.usd().balances.call('0x87ed145761f0b0417f62c7e2e1e384ca4f9197d2')
// boa.usd().getUSDBalance.call('0x87ed145761f0b0417f62c7e2e1e384ca4f9197d2').toString()
// boa.usd().balances.call('0xdf85292658a69ade0b271d082234760474f98b6d').toString()

// boa.usd().balances.call('0xdf85292658a69ade0b271d082234760474f98b6d').add(0)

// new BigNumber(0)
// boa.usd().getUSDBalance.call('0xdf85292658a69ade0b271d082234760474f98b6d').toString()
// // //Bank.boa.atomicSwapUsd()
// // //.usd().getUSDBalance.call('0x2ad225137688317b4e57f017114a11253b389f0d').toString()


// var event = boa.usd().allEvents({fromBlock:0, toBlock:"latest"});
// var d = event.watch(function (err, result) {
//     if (err) {console.log(err);}
//     console.log(result.args);
// });



// Bank.addresses['0x87ed145761f0b0417f62c7e2e1e384ca4f9197d2']

// var minutes = 30;
// var from = boa.address;
// var gas = 0x47b760;
// boa.web3.personal.unlockAccount(boa.address);
// boa.atomicSwapUsd().lock.sendTransaction(icici.address, hash, minutes, 1000, {from, gas}, (e, txnHash) => {
//     if (e) {
//         console.error(e);
//     }
//     console.log(txnHash);
// });

// var a = boa.atomicSwapUsd().lock;

// var event = boa.atomicSwapUsd().allEvents({fromBlock:0, toBlock:"latest"});
// var d = event.watch(function (err, result) {
//     if (err) {console.log(err);}
//     console.log(result.args);
// });


// var event = boa.atomicSwapUsd().usdLocked({fromBlock:0, toBlock:"latest"})
// var d = event.watch(function (err, result) {
//     if (err) {console.log(err);}
//     console.log(result.args);
// });


//           //Lock 1000 USD for 30 min
//           atomicSwapUSDContractInstance.lock.sendTransaction(ICICI_Address, hash, 
//     30, 1000, {from: BOA_Address, gas: 4712388}, function(e, txnHash){  
//             //Fetch USD Balance
//             console.log("USD Atomic Exchange Smart Contracts holds : " + 
//               usdContractInstance.getUSDBalance.call
//               (atomicSwapUSDAddress).toString())
  
//             //Lock 1000 INR for 15 min
//             atomicSwapINRContractInstance.lock.sendTransaction(BOA_Address,
//     hash, 15, 1000, {from: ICICI_Address, gas: 4712388},



// Issue USD - done
// usdContractInstance.issueUSD.sendTransaction(BOA_Address, 1000,
//     {from: FRS_Address}, function(e, txnHash){
  
//     //Fetch USD Balance -done 
//     console.log("Bank of America's USD Balance is : " + 
//       usdContractInstance.getUSDBalance.call(BOA_Address).toString())
    
//     //Issue INR -done
//     inrContractInstance.issueINR.sendTransaction(ICICI_Address, 1000,
//      {from: RBI_Address}, function(e, txnHash){
  
//       //Fetch INR Balance-done
//       console.log("ICICI Bank's INR Balance is : " + 
//         inrContractInstance.getINRBalance.call(ICICI_Address).toString())
  
//       //Generate Secret and Hash-done
//       var secret = generateSecret();
//       var hash = atomicSwapUSDContractInstance.calculateHash.call(secret,
//         {from: BOA_Address});
  
//       //Give Access to Smart Contract-done
//       usdContractInstance.approve.sendTransaction(atomicSwapUSDAddress,
//         1000, {from: BOA_Address}, function(e, txnHash){
  
//         //Give Access to Smart Contract-done
//         inrContractInstance.approve.sendTransaction(atomicSwapINRAddress,
//           1000, {from: ICICI_Address}, function(e, txnHash){
  
//           //Lock 1000 USD for 30 min
//           atomicSwapUSDContractInstance.lock.sendTransaction(ICICI_Address, hash, 
//     30, 1000, {from: BOA_Address, gas: 4712388}, function(e, txnHash){
  
//             //Fetch USD Balance
//             console.log("USD Atomic Exchange Smart Contracts holds : " + 
//               usdContractInstance.getUSDBalance.call
//               (atomicSwapUSDAddress).toString())
  
//             //Lock 1000 INR for 15 min
//             atomicSwapINRContractInstance.lock.sendTransaction(BOA_Address,
//     hash, 15, 1000, {from: ICICI_Address, gas: 4712388},
//     function(e, txnHash){
  
//               //Fetch INR Balance
//               console.log("INR Atomic Exchange Smart Contracts holds : "
//                 + inrContractInstance.getINRBalance.call
//                 (atomicSwapINRAddress).toString())
  
//               atomicSwapINRContractInstance.claim(secret, {
//                 from: BOA_Address, gas: 4712388
//               }, function(error, txnHash){
                
//                 //Fetch INR Balance
//                 console.log("Bank of America's INR Balance is : " +
//                   inrContractInstance.getINRBalance.call
//                   (BOA_Address).toString())
  
//                 atomicSwapUSDContractInstance.claim(secret, {
//                   from: ICICI_Address, gas: 4712388
//                 }, function(error, txnHash){
                  
//                   //Fetch USD Balance
//                   console.log("ICICI Bank's USD Balance is : " +
//                     usdContractInstance.getUSDBalance.call
//                     (ICICI_Address).toString())
//                 })
  
//               })
              
//             })
//           })
//         })
        
//       })
//     })
    
//   }) 


//.then(a=> deployContract(Bank["FRS"], compiled.contracts[":AtomicSwap_USD"], a)).then(console.log)
// distributeFundsAcross(Bank).then(d=>deployContract(Bank["FRS"], compiled.contracts[":USD"]))
//                            .then(a=> deployContract(Bank["FRS"], compiled.contracts[":AtomicSwap_USD"], a)).then(console.log)
//.then(console.log)
//                           .then(a=> deployContract(Bank["FRS"], compiled.contracts[":AtomicSwap_USD"], a)).then(console.log)

// .then(data => {
//     var frs = Bank["FRS"];
//     var boa = Bank["BOA"];
//     return new Promise((resolve, reject) => {
//         var process = (e, txnHash) => {
// //          var bal  bnbnance = boa.usd().getUSDBalance.call(boa.address).toString();
//             Bank.reg.forEach(bank => {
//                 var balance = bank.usd().getUSDBalance.call(bank.address).toString();
//                 console.log(`${bank.description}'s USD Balance is : ${balance}`);
//             })
//             //console.log(`Bank of America's USD Balance is : ${balance}`);
//             //TODO: have to add logs to solidity contracts
//             var tx = frs.web3.eth.getTransactionReceipt(txnHash);
//             if (e) {
//                 reject(e);
//             } else {
//                 resolve(txnHash);
//             }
//         };
//         frs.usd().issueUSD.sendTransaction(boa.address, 1000, {from: frs.address}, process);
//     });
// }).then(txnHash => {
//     console.log("success so far");
//     Bank.reg.forEach(bank => {
//         var balance = bank.usd().getUSDBalance.call(bank.address).toString();
//         console.log(`${bank.description}'s USD Balance is : ${balance}`);
//     });
// });







/////////////////////////////////




//random testing 
// var frs = Bank["FRS"];
// var boa = Bank["BOA"];

// var t;
// frs.web3.personal.unlockAccount(frs.address)
// frs.host
// frs.usd().issueUSD.sendTransaction(boa.address, 1, {from: frs.address}, (e, result)=>{
//     if (e) {
//         console.log(e);
//     } else {
//         t = result;
//         console.log(result);
//     }
// });
//{fromBlock: 0, toBlock: 'latest'}
// var w = 
// Object.keys(frs.usd())

// frs.usd().Debug().watch( function(error, result){
//     console.log(result.args.what);
// }).requestManager.polls['0x4379016798b051c4f757ac7e7927aee9']

// .requestManager.pools['0x4379016798b051c4f757ac7e7927aee9'];

// Bank.reg.forEach(bank => {
//     var balance = bank.usd().getUSDBalance.call(bank.address).toString();
//     console.log(`${bank.description}'s USD Balance is : ${balance}`);
// });

// Bank.reg.forEach(bank => {
//     bank.web3.personal.unlockAccount(bank.address);
//     bank.usd().issueUSD.sendTransaction(boa.address, 1, {from: bank.address}, (e, result)=>{
//         if (e) {
//             console.log(e);
//         } else {
//             t = result;
//             console.log(result);
//         }
//     });
// });



// frs.usd()

// frs.web3.eth.getTransactionReceipt(t)

// Bank.reg.forEach(bank => {
//     var balance = bank.usd().getUSDBalance.call(bank.address).toString();
//     console.log(`${bank.description}'s USD Balance is : ${balance}`);
// });

// Object.keys(compiled.contracts[':USD'].functionHashes)
// compiled.contracts[':USD'].functionHashes
// compiled.contracts[':USD'].opcodes
// .search('5c658165'.toUpperCase())
// 0xa7
// 0x23
// _.mapValues(_.groupBy(compiled.contracts[':USD'].opcodes.split(" "), o=>o.slice(0, 4).toUpperCase()), val => {
//     return val.length;/
// });


// _.pickBy(_.mapValues(_.groupBy(compiled.contracts[':USD'].opcodes.split(" "), o=>o.slice(0, 4).toUpperCase()), v=>{
//     return _.uniq(v)
// }), (value, key) =>{
//     return key.slice(0, 4).toUpperCase() === '0xa7'.toUpperCase() || key.slice(0, 4).toUpperCase() === '0x23'.toUpperCase();
// });
// //{ '0X23': [ '0x2322E3B9' ], '0XA7': [ '0xA7587BFB' ] }
// compiled.contracts[':USD'].functionHashes


