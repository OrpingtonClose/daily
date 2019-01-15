pragma solidity ^0.4.17;

library math {
    function addInt(int a, int b) public pure returns (int c) {
        return a + b;
    }
}

contract sample {
    function data() public pure returns (int d) {
        return math.addInt(1, 2);
    }
}