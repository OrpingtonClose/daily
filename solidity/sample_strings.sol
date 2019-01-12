pragma solidity ^0.4.17;

contract sample{
    string myString = "";
    bytes myRawString;

    function sample(string initString, bytes rawStringInit) {
        myString = initString;
        //pointer
        string myString2 = myString;
        string memory myString3 = "ABCDE";
        myString3 = "XYZ";
        myRawString = rawStringInit;
        myRawString.length++;
        //string literals are memory;
        //string myString4 = "Example";
        //string myString5 = initString;
    }
}