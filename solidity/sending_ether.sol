pragma solidity ^0.4.13;

contract SomeContractWithRandomThings {
    mapping (address => uint) balances;
    
    function deposit() payable {
        balances[msg.sender] += msg.value;
    } 
    
    function dontDoThis1(uint amount) {
        if (balances[msg.sender] >= amount) {
            msg.sender.send(amount);
            balances[msg.sender] -= amount;
        }
    }
    
    function dontDoThis2(uint amount) {
        if (balances[msg.sender] >= amount) {
            //what the hell is this
            msg.sender.call.gas(2500000).value(amount)();
            balances[msg.sender] -= amount;
        }
    }
    
    function dontDoThis3(uint amount) {
        if (balances[msg.sender] >= amount) {
            if(msg.sender.call.gas(2500000).value(amount)()){
                balances[msg.sender] -= amount;
            }
        }
    }
    
    function dontDoThis4(uint amount) {
        if (balances[msg.sender] >= amount) {
            if(msg.sender.send(amount)) {
                balances[msg.sender] -= amount;
            }
        }
    }
    
    function dontDoThis5(uint amount) {
        if (balances[msg.sender] >= amount) {
            balances[msg.sender] -= amount;
            if (!msg.sender.send(amount)) {
                throw;
            }
        }
    }
    
    function dontDoThis6(uint amount) {
        if (balances[msg.sender] >= amount) {
            balances[msg.sender] -= amount;
            if (!msg.sender.call.gas(2500000).value(amount)()) {
                throw;
            }
        }
    }
    
    function doThis1(uint amount) {
        if (balances[msg.sender] >= amount) {
            balances[msg.sender] -= amount;
            msg.sender.transfer(amount);
        }
    }
    
    function doThis2(uint amount) {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        msg.sender.transfer(amount);
    }
}
