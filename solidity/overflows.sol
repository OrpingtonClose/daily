pragma solidity ^0.4.13;

contract Overflows {
  function overflow_check(uint num_to_add) public pure returns (uint) {
    return uint256(~0) + num_to_add; 
  }
  function underflow_check(uint num_to_subtract) public pure returns (uint) {
    return uint256(0) - num_to_subtract; 
  }
}
