pragma solidity ^0.4.8;
// https://github.com/ethereum/EIPs/issues/20

contract ERC20Interface {
    function totalSupply() constant returns (uint256 totalSupply);
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract UnitCoin is ERC20Interface {
    string public name = "Everything";
    striny public symbol = "ALL";
    uint8 public decimals = 0;


    address _current_owner;
    address _current_delegate;
    function UnitCoin() {
        _current_owner = msg.sender;
    }

    function totalSupply() constant returns (uint256 totalSupply) {
        totalSupply = 1;
    }
    function balanceOf(address _owner) constant returns (uint256 balance) {
        if (_owner == _current_owner) {
            balance = 1;
        } else {
            balance = 0;
        }
    }
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (_value == 1 && _current_owner == msg.sender) {
            _current_owner = _to;
            _current_delegate = 0;
            success = true;
        }
    }
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (_value == 1 && _current_delegate == msg.sender) {
            _current_owner = _to;
            _current_delegate = 0;
            success = true;
        }
    }
    function approve(address _spender, uint256 _value) returns (bool success) { 
        if (_value == 1 && _current_owner == msg.sender) {
            _current_delegate = _spender;
            success = true;
        }
    }
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        if (_owner == _current_owner && _spender == _current_delegate) {
            remaining = 1;
        } else {
            remaining = 0;
        }
    }
}
