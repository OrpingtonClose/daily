pragma solidity ^0.4.17;

contract sample1 {
    function a() returns (int b);
}

contract sample2 {
    function myFunc() {
        sample1 s = sample1(0x0000000000000000000000000000000000000000);
        s.a();
    }
}