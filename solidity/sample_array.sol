pragma solidity ^0.4.17;

contract sample{
    int[] myArray = [0, 0];

    function sample(uint index, int value) {
        myArray[index] = value;
        int[] myArray2 = myArray;
        uint24[3] memory myArray3 = [1, 2, 99999];
        //array literals are memory default complex types
        //uint8[2] myArray4 = [1, 2];
    }
}