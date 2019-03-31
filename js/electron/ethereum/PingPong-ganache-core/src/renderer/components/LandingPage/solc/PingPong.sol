pragma solidity ^0.5.0;
// https://github.com/ethereum/EIPs/issues/20
//[{"constant":false,"inputs":[{"name":"who","type":"address"}],"name":"send","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"currentOwner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"from","type":"address"},{"indexed":false,"name":"to","type":"address"}],"name":"PongDone","type":"event"}]
//608060405234801561001057600080fd5b50336000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055506101ba806100606000396000f3fe608060405234801561001057600080fd5b50600436106100365760003560e01c80633e58c58c1461003b578063b387ef921461007f575b600080fd5b61007d6004803603602081101561005157600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff1690602001909291905050506100c9565b005b610087610165565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b3373ffffffffffffffffffffffffffffffffffffffff166000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff161461012257600080fd5b806000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff16021790555050565b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1690509056fea165627a7a72305820e8ace6866abdcd1318136085c77afa8571d6f9e6d938ec461a82acabd5f8f65a0029
contract PingPong {

    event PongDone(address from, address to);
    address _current_owner;

    string public name = "PingPong";

    constructor() public {
        _current_owner = msg.sender;
        emit PongDone(address(0), _current_owner);
    }

    function currentOwner() public view returns (address) {
        return _current_owner;
    }

    function send(address who) public {
        require(_current_owner == msg.sender);
        _old_owner = _current_owner;
        _current_owner = who;
        emit PongDone(_old_owner, _current_owner);
    }

}
