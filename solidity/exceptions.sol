
aragma solidity ^0.4.13; solidity ^0.4.13;

contract secondContract {
    uint public counter = 0;
    
    function increaseNumber() {
        counter++;
    }
    
    function revertThis() {
        revert();
    }
    
    function() payable {
        revertThis();
    }
}

contract ThrowingDifferentThings {
    
    secondContract _s;
    
    function ThrowingDifferentThings() {
        _s = new secondContract();
    }
    
    function throwInSecondContract() {
        _s.revertThis();
    }
    
    function callSendContractWithTransfer() payable {
        _s.transfer(msg.value);
    }
    
    function changeWithRevert() {
        _s.increaseNumber();
        revert();
    }    
    
    function callSecondContract() payable {
        _s.call.gas(100000).value(msg.value)(msg.data);
    }
    
    function sendSecondConteact() payable {
        _s.send(msg.value);
    }
    
    function outOfBounds() {
        uint[] memory myArray = new uint[](10);
        myArray[11] = 10;
    }

    function getNumber() constant returns (uint) {
        return _s.counter();
    }

    function divideByZero() {
        uint someVar = 0;
        uint someOtherVar = 50;
        uint third = someOtherVar / someVar;
        third = 1;
    }

    function shiftByNegative() {
        uint someVar = 1;
        int shiftVar = -1;
        someVar << shiftVar;
    }

    function makeAssert() {
        assert(false);
    }

    function makeThrow() {
        throw;
    }

    function makeRequire() {
        require(false);
    }

    function makeRevert() {
        revert();
    }
}


contract ThrowingDifferentThings {
    function outOfBounds() {
        myArray[11] = 10;
    }
    
    function divideByZero() {
        uint someVar = 0;
        uint someOtherVar = 50;
        uint third = someOtherVar / someVar;
        third = 1;
    }
    
    function shiftByNegative() {
        uint someVar = 1;
        int shiftVar = -1;
        someVar << shiftVar;
    }

    function makeAssert() {
        assert(false);
    }
    
    function makeThrow() {
        throw;
    }
    
    function makeRequire() {
        require(false);
    }
    
    function makeRevert() {
        revert();
    }
}
