pragma solidity ^0.4.17;

library math {
    struct myStruct1 {
        int a;
    }
    struct myStruct2{
        int a;
    }
    function addInt(myStruct1 storage s, int b) public view returns (int c) {
        return s.a + b;
    }
    function subInt(myStruct2 storage s, int b) public view returns (int c) {
        return s.a + b;
    }
}

contract sample {
    using math for *;
    math.myStruct1 s1;
    math.myStruct2 s2;

    function stample() public {
        s1 = math.myStruct1(11);
        s2 = math.myStruct2(22);
        s1.addInt(2);
        s2.subInt(1);
    }
}