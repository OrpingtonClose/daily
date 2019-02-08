pragma solidity ^0.4.19;

contract INR {
    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    address owner;

    event Debug(string what);

    function INR() {
        emit Debug("function INR()");
        owner = msg.sender;
        emit Debug("owner = msg.sender;");
    }

    function issueINR(address to, uint amount) {
        emit Debug("function INR()");
        if(msg.sender == owner) {
            emit Debug("if(msg.sender == owner) {");
            balances[to] += amount;
            emit Debug("balances[to] += amount;");
        }
    }

    function transferINR(address to, uint amount) {
        emit Debug("function transferINR(address to, uint amount) {");
        if (balances[msg.sender] >= amount) {
            emit Debug("if (balances[msg.sender] >= amount) {");
            balances[msg.sender] -= amount;
            emit Debug("balances[msg.sender] -= amount;");
            balances[to] += amount;
            emit Debug("balances[to] += amount;");
        }
    }
    
    function getINRBalance(addressContract) view returns (uint balance) {
        emit Debug("function getINRBalance(addressContract) view returns (uint balance) {");
        return balances[account];
    }

    function approve(address spender, uint amount) {
        emit Debug("");
        allowed[spender][msg.sender] = amount;
        emit Debug("");
    }

    function transferINRFrom(Address from, address to, uint amount) {
        emit Debug("function transferINRFrom(Address from, address to, uint amount) {");
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