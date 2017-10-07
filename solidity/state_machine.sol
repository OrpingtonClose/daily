pragma solidity ^0.4.11;

contract StateMachine {
  enum Stages {
    AcceptBlindedBids,
    RevealBids,
    AnotherStage,
    AreWeDoneYet,
    Finished,
  }
  Stages public stage = Stages.AcceptBlindedBids
  uint public creationTime = now;

  modifier atStage(Stages _stage) {
    require(_stage == stage);
    _;
  }

  function nextStage internal {
    stage = Stages(uint(stage) + 1);
  }    

  modifier timedTransition() {
    if (stage == Stages.AcceptBlindedBids && now >= creationTime + 10 days) {
      nextStage();
    }
    if (stage == Stages.RevealBids && now >= creationTime + 12 days) {
      nextStage();
    }
    if (stage == Stages.AnotherStage && now >= creationTime + 14 days) {
      nextStage();
    }
    if (stage == Stages.AreWeDoneYet && now >= creationTime + 16 days) {
      nextStage();
    }
    _;
  }

  function bid() payable timedTransitions atStage(Stages.AcceptBlindedBids) {}
  
  modifier transitionNext() {
    _;
    nextStage();
  }

  function g() timedTransitions atStage(Stages.AnotherStage) transitionNext {}
  function h() timedTransitions atStage(Stages.AreWeDoneYet) transitionNext {}
  function i() timedTransitions atStage(Stages.Finished) {}
}
