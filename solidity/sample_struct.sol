pragma solidity ^0.4.17;

contract sample{
    struct myStruct {
        bool myBool;
        string myString;
    }
    myStruct s1;
    myStruct s2 = myStruct(true, "");
    function sample(bool initBool, string initString) {
        s1 = myStruct(initBool, initString);
        myStruct memory s3 = myStruct(initBool, initString);
    }
}