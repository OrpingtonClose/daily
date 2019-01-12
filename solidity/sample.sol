pragma solidity ^0.4.17;

contract Sample {
    uint256 data;
    address owner;

    event logData(uint256 dataToLog);

    modifier onlyOwner() {
        if (msg.sender != owner) throw;
        _;
    }

    function Sample(uint256 initData, address initOwner) {
        data = initData;
        owner = initOwner;
    }

    function getData() returns (uint256 returnedData) {
        return data;
    }

    function setData(uint256 newData) onlyOwner {
        logData(newData);
        data = newData;
    }
}