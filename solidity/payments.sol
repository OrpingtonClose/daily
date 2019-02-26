pragma solidity ^0.4.18;

contract USD {
    address centralBank;
    mapping (address => uint256) balances;
    uint256 totalDestroyed;
    uint256 totalIssued;

    event usdIssued(uint256 amount, address to);    
    event usdDestroyed(uint256 amount, address from);
    event usdTransfered(uint256 amount, address from, address to, string description);

    constructor() {
        centralBank = msg.sender;
    }    

    function issueUSD(uint256 amount, address to) {
        if(msg.sender == centralBank) {
            balances[to] += amount;
            totalIssued += amount;
            emit usdIssued(amount, to);
        }
    }
    function destroyUSD(uint256 amount) {
        require(balances[msg.sender] >= amount, "balance not high enough");
        balances[msg.sender] -= amount;
        totalDestroyed += amount;
        emit usdDestroyed(amount, msg.sender);
    }
    function transferUSD(uint256 amount, address to, string description) {
        if(balances[msg.sender] >= amount) {
            balances[msg.sender] -= amount;
            balances[to] += amount;
            emit usdTransfered(amount, msg.sender, to, description);
        }
    }    
    function getBalance(address account) returns (uint256) {
        return balances[account];
    }
    function getTotal() returns (uint256, uint256) {
        return (totalDestroyed, totalIssued);
    }
}

contract MobileNumbers {
    address centralBank;
    struct BankDetails {
        string name;
        bool authorization;
    }
    mapping (address => BankDetails) banks;
    mapping (uint256 => address[]) mobileNumbers;
    event bankAdded(address bankAddress, string bankName);
    event bankRemoved(address bankAddress);
    event mobileNumberAdded(address bankAddress, uint256 mobileNumber);

    constructor() {
        centralBank = msg.sender;
    }

    function addBank(address bank, string bankName) {
        require(centralBank == msg.sender);
        banks[bank] = BankDetails(bankName, true);
        emit bankAdded(bank, bankName);
    }

    function removeBank(address bank) {
        require(centralBank == msg.sender);
        banks[bank].authorization = false;
        emit bankRemoved(bank);
    }

    function getBankDetails(address bank) view returns (string, bool) {
        return (banks[bank].name, banks[bank].authorization);
    }

    function addMobileNumber(uint mobileNumber) {
        require(banks[msg.sender].authorization == true);
        for (uint256 count = 0; count < mobileNumbers[mobileNumber].length; count++) {
            if (mobileNumbers[mobileNumber][count] == msg.sender) {
                return;
            }
        }
        mobileNumbers[mobileNumber].push(msg.sender);
        emit mobileNumberAdded(msg.sender, mobileNumber);
    }
    function removeMobileNumber(uint mobileNumber) {
        require(banks[msg.sender].authorization == true);
        for (uint256 count = 0; count < mobileNumbers[mobileNumber].length; count++) {
            if (mobileNumbers[mobileNumber][count] == msg.sender) {
                delete mobileNumbers[mobileNumber][count];
                for (uint i = count; i < mobileNumbers[mobileNumber].length - 1; i++) {
                    mobileNumbers[mobileNumber][i] = mobileNumbers[mobileNumber][i+1];
                }
                mobileNumbers[mobileNumber].length--;
                break;
            }
        }        
    }
    function getMobileNumberBanks(uint256 mobileNumber) view returns (address[]) {
        return mobileNumbers[mobileNumber];
    }
}