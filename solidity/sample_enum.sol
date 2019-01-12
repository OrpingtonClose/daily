pragma solidity ^0.4.17;

contract sample{
    enum OS { Windows, Linux, OSX, UNIX }
    OS choice;
    function sample(OS chosen) public {
        choice = chosen;
    }
    function setLinuxOS() public {
        choice = OS.Linux;
    }
    function getChoice() public view returns (OS chosenOS) {
        return choice;
    }
}