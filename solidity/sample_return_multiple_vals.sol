pragma solidity ^0.4.17;

contract sample {
    function a() returns (int a, string c) {
        return (1, "ss");
    }
    function b() {
        int A;
        string memory B;

        (A, B) = a();
        (, B) = a();
        (A, ) = a();
    }
}