pragma solidity ^0.4.17;

contract sample1 {
    function a() {}
    function b() {}
}

contract sample2 is sample1 {
    function b() {}
} 

contract sample3 {
    function sample3(int b) {

    }
}

contract sample4 is sample1, sample2 {
    function a() {}
    function c() {
        a();
        sample1.a(); 
        b(); //sample2.b();
    }
}

contract sample5 is sample3(122) {

}