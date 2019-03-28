//https://ethereumbuilders.gitbooks.io/guide/content/en/solidity_tutorials.html
pragma solidity ^0.5.1;

contract SimpleStorage {
  uint storedData;
  function set(uint x) public {
    storedData = x;
  }
  function get() view public returns (uint retVal) {
    return storedData;
  }
}
