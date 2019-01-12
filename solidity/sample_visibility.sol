pragma solidity ^0.4.17;

contract sample1 {
    int public b = 78;
    int internal c = 90;
    function a() external {

    }

    function sample1() {
        int dump;
        this.a();
        //a(); //throws
        b = 21;
        dump = this.b();
        //dump = this.b(8); //throws
        //dump = this.c(); //throws
        c = 9;
    }
}

contract sample2 {
    int internal d = 9;
    int private e = 90;
}

contract sample3 is sample2 {
    sample1 s;
    function sample3() {
        int dump;
        s = new sample1();
        s.a();
        var f = s.b;
        //s.b = 18; //accessor cannot used to assign a value
        //s.c();
        d = 8;
        //e = 7;
    }
}