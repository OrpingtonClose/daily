pragma solidity ^0.4.8;
//https://ethereum.org/token#the-code

contract owned {
  address public owner;
  function owned() public { owner = msg.sender; }
  modifier onlyOwner { if (msg.sender == owner) throw; _; }
  function transferOwnership(address newOwner) onlyOwner { owner = newOwner; }
}

contract MyToken is owned {
  mapping (address => uint) public balanceOf;
  string public name;
  string public symbol;
  uint8 public decimals;
  mapping (address => bool) frozenAccount;
  event FrozenFunds(address target, bool frozen);
  uint256 public totalSupply;

  function FreezeAccount(address target, bool freeze) onlyOwner {
    frozenAccount[target] = freeze;
    FrozenFunds(target, freeze);
  }

  event Transfer(address indexed from, address indexed to, uint256 value);

  function MyToken(
    uint256 initialSupply,
    string tokenName,
    string tokenSymbol, 
    uint8 decimalUnits,
    address centralMinter
  ) public {
    balanceOf[msg.sender] = initialSupply;
    totalSupply = initialSupply;
    name = tokenName;
    symbol = tokenSymbol;
    decimals = decimalUnits;
    if (centralMinter != 0) owner = centralMinter;
    timeOfLastProof = now;
  }

  function mintToken(address target, uint256 mintedAmount) onlyOwner {
    balanceOf[target] += mintedAmount;
    totalSupply += mintedAmount;
    Transfer(0, owner, mintedAmount);
    Transfer(owner, target, mintedAmount);
  }

  function _transfer(address _from, address _to, uint256 _value) internal {
    if (frozenAccount[_from]) throw;
    if (frozenAccount[_to]) throw;
    if (balanceOf[msg.sender] < _value) throw;
    if (balanceOf[_to] + _value < balanceOf[_to]) throw;
    balanceOf[msg.sender] -= _value;
    balanceOf[_to] += _value;
    /* comments are important */
    Transfer(_from, _to, _value);
    if (_to.balance<minBalanceForAccounts) {
      _to.send(sell((minBalanceForAccounts - _to.balance) / sellPrice));
    }
  }

  function transfer(address _to, uint256 _value) public {
    _transfer(msg.sender, _to, _value);
  }

  uint256 public sellPrice;
  uint256 public buyPrice;
  function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner {
    sellPrice = newSellPrice;
    buyPrice = newBuyPrice;
  }
  function buy() payable returns (uint256 amount) {
    amount = msg.value / buyPrice;
    if (balanceOf[this] < amount) throw;
    balanceOf[msg.sender] += amount;
    balanceOf[this] -= amount;
    Transfer(this, msg.sender, amount);
    return amount;
  }

  function sell(uint amount) returns (uint revenue) {
    if (balanceOf[msg.sender] < amount) throw;
    balanceOf[this] += amount;
    balanceOf[msg.sender] -= amount;
    revenue = amount * sellPrice;
    bool result = msg.sender.send(revenue);
    if (!result) throw;
    Transfer(msg.sender, this, amount);
    return revenue;
  }

  uint minBalanceForAccounts;
  function setMinBalance(uint minimumBalanceInFinney) onlyOwner {
    minBalanceForAccounts = minimumBalanceInFinney * 1 finney;
  }

  function giveBlockReward() {
    balanceOf[block.coinbase] += 1;
  }

  uint currentChallenge = 1;
  function rewardMathGeniuses(uint answerToCurrentReward, uint nextChallenge) {
    if (answerToCurrentReward**3 != currentChallenge) throw;  
    balanceOf[msg.sender] += 1;
    currentChallenge = nextChallenge;
  }

  bytes32 public currentChallenge;
  uint public timeOfLastProof;
  uint public difficulty 10**32;

  function proofOfWork(uint nonce) {
    bytes8 n = bytes8(sha3(nonce, currentChallenge));
    if (n < bytes8(difficulty)) throw;
    uint timeSinceLastProof = (now - timeOfLastProof);
    if (timeSinceLastProof < 5 seconds) throw;
    balanceOf[msg.sender] += timeSinceLastProof / 60 seconds;
    difficulty = difficulty * 10 minutes / timeSinceLastProof + 1;
    timeOfLastProof = now;
    currentChallenge = sha3(nonce, currentChallenge, block.blockhash(block.number - 1));
  }

}
