pragma solidity ^0.4.11;

contract WithdrawContract {
  address public richest;
  uint public mostSent;

  mapping (address => uint) pendingWithdrawal;

  function WithdrawContract() payable {
    richest = msg.sender;
    mostSent = msg.value;
  }

  function becomeRichest() payable returns (bool) {
    if (mostSent < msg.value) {
      pendingWithdrawal[richest] += msg.value;
      richest = msg.sender;
      mostSent = msg.value;
      return true;
    } else {
      return false;
    }
  }

  function withdraw() {
    uint amount = pendingWithdrawal[msg.sender];
    pendingWithdrawal[msg.sender] = 0;
    msg.sender.transfer(amount);
  }
}
