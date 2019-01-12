pragma solidity ^0.4.17;

contract sample1 {}
contract sample2 {}
contract sample3 is sample2 {}
contract sample4 is sample2 {}
contract sample5 is sample4 {
    function myFunc() {}
}
contract sample6 is sample1, sample2, sample3, sample5 {
    function myFunc() {
        super.myFunc(); //from sample5.myFunc;
    }
}