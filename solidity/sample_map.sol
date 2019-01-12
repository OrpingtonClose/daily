pragma solidity ^0.4.17;

contract sample {
    mapping (int => string) myMap;
    function sample(int key, string value) {
        myMap[key] = value;
        mapping (int => string) myMap2 = myMap;
    }
}