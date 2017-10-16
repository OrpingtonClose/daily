pragma solidity ^0.4.12;

contract ToBeCalled {
  event ReceivedFunds(uint amount, address from);
  event FindsSent();
  function takeSomeFunds() payable {
    ReceivedFunds(msg.value, msg.sender);    
  }

  function withdraw() {
    msg.sender.send(1);
    FundsSent(); 
  }
}

