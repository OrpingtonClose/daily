pragma solidity ^0.4.17;

contract sample {
    struct Struct {
        mapping (int => int) myMap;
        int myNumber;
    }

    int[] myArray;
    Struct myStruct;

    function sample(int key, int value, int number, int[] array) {
        //maps can't be assigned
        myStruct = Struct(number);
        myStruct.myMap[key] = value;
        myArray = array;
    }
    function reset() {
        delete myArray;
        delete myStruct;
    }

    function deleteKey(int key) {
        delete myStruct.myMap[key];
    }
}