pragma solidity ^0.4.17;
//uses quorum private transactions
contract Proof {
    struct FileDetails{
        uint timestamp;
        string owner;
    }

    mapping (string => FileDetails) files;
    event logFileAddedStatus(bool status, uint timestamp, string owner, string fileHash);

    function set(string owner, string fileHash) {
        if(files[fileHash].timestamp == 0){
            files[fileHash] = FileDetails(block.timestamp, owner);
            logFileAddedStatus(true, block.timestamp, owner, fileHash);
        } else {
            logFileAddedStatus(false, block.timestamp, owner, fileHash);
        }
    }
    function get(string fileHash) returns (uint timestamp, string owner) {
        FileDetails file = files[fileHash];
        return (file.timestamp, file.owner);
    }
}