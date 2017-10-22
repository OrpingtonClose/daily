pragma solidity ^0.4.13;

contract Adder {
    function add(uint a, uint b) constant public returns (uint sum) {
        assembly {
            sum := add(a, b)
            sum := add(sum, b)
        }
    }
    function add1(uint a, uint b) constant public returns (uint sum) {
        assembly {
            mstore(0x00, add(a, b))
            return(0x00, 32)
        }
    }
    function add2(uint a, uint b) constant public returns (uint sum) {
        assembly {
            b
            a
            add
            0x00
            mstore
            32
            0x00
            return
        }
    }
    function overflow_check(uint num_to_add) public pure returns (uint) {
        return uint256(~0) + num_to_add; 
    }
    function underflow_check(uint num_to_subtract) public pure returns (uint) {
        return uint256(0) - num_to_subtract; 
    }
}
