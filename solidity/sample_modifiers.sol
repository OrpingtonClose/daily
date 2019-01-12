pragma solidity ^0.4.17;

contract sample {
    int a = 90;
    modifier myModifier1(int b) {
        int c = b;
        _;
        c = a;
        a = 8;
    }
    modifier myModifier2 {
        int c = a;
        _;
    }
    modifier myModifier3 {
        a = 96;
        return;
        _;
        a = 99;
    }
    modifier myModifier4 {
        int c = a;
        _;
    }
    function myFunction() myModifier1(a) myModifier2 myModifier3 returns (int d) {
        a = 1;
        return a;
    }
}