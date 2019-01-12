pragma solidity ^0.4.17;

contract sample1 {
    int a;
    function sample1(int b) payable {
        a = b;
    }
    function assign(int c) {
        a = c;
    }
    function makePayment(int d) payable {
        a = d;
    }
}

contract sample2 {
    function hello(){}
    function sample2(address addressOfContract) {
        //send 12 wei while creating contract
        sample1 s = (new sample1).value(12)(23);
        s.makePayment(22);
        s.makePayment.value(45)(12);
        s.makePayment.gas(895)(12);
        s.makePayment.value(4).gas(900)(12);
        this.hello(); //external call
        //already deployed
        sample1 s2 = sample1(addressOfContract);
        s2.makePayment(112);
    }
}