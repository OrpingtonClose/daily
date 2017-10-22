pragma solidity ^0.4.13;

import "./owned.sol";
import "./FixedSupplyToken.sol";

contract Exchange is owned {
//  struct Offer {
//    uint amount;
//    address who;
//  }
//  struct OrderBook {
//    uint higherPrice;
//    uint lowerPrice;
//    mapping (uint => Offer) offers;
//    uint offers_key;
//    uint offers_length;
//  }
//  struct Offer {
//    uint amount;
//    uint price;
//    address who;
//  }
//  struct Token {
//    address tokenContract;
//    string symbolName;
//    mapping (uint => Offer[]) buyBook;
//    uint curBuyPrice;
//    uint lowestBuyPrice;
//    uint amountBuyPrices;
//
//    mapping (uint => Offer[]) sellBook;
//    uint curSellPrice;
//    uint highestSellPrice;
//    uint amountSellPrices;
//  }

  struct Offer {
    uint amount;
    uint price;
    address who;
  }
  struct Token {
    address tokenContract;
    string symbolName;
    Offer[] buyBook;
    Offer[] sellBook;
  }

  event DepositForTokenReceived(address indexed _from, uint indexed _symbolIndex, uint _amount, uint _timestamp);
  event DepositForEthReceived(address indexed _from, uint _amount, uint _timestamp);
  event WithdrawalToken(address indexed _to, uint indexed _symbolIndex, uint _amount, uint _timestamp);
  event WithdrawalEth(address indexed _to, uint _amount, uint _timestamp);

  event LimitSellOrderCreated(uint indexed _symbolIndex, address indexed _who, uint _amountTokens, uint _orderKey);
  event LimitBuyOrderCreated(uint indexed _symbolIndex, address indexed _who, uint _amountTokens, uint _orderKey);
  event SellOrderFullfilled(uint indexed _symbolIndex, uint _amount, uint _priceInWei, uint _orderKey);
  event BuyOrderFullfilled(uint indexed _symbolIndex, uint _amount, uint _priceInWei, uint _orderKey);
  event SellOrderCancelled(uint indexed _symbolIndex, uint _priceInWei, uint _orderKey);
  event BuyOrderCancelled(uint indexed _symbolIndex, uint _priceInWei, uint _orderKey);

  event TokenAddedToSystem(uint _symbolIndex, string _token, uint _timestamp);

  mapping (uint8 => Token) tokens;
  uint8 symbolNameIndex;

  mapping (address => mapping (uint8 => uint)) tokenBalanceForAddress;
  mapping (address => uint) balanceEthForAddress;

  function depositToken(string symbolName, uint amount) {
    uint8 index = getSymbolIndex(symbolName);
    require(index != 0);

    address erc20Token = tokens[index].tokenContract;
    ERC20Interface erc20 = ERC20Interface(erc20Token);
    uint allowed_balance = erc20.allowance(msg.sender, this);
    require(allowed_balance >= amount);

    uint balance_at_exchange = tokenBalanceForAddress[msg.sender][index];
    require(balance_at_exchange + amount >= balance_at_exchange);

    tokenBalanceForAddress[msg.sender][index] += amount;
    erc20.transferFrom(msg.sender, this, amount);
    DepositForTokenReceived(msg.sender, index, amount, now);
    /* it looks like it's working! */
  }

  function withdrawToken(string symbolName, uint amount) {
    uint8 index = getSymbolIndex(symbolName);
    require(index != 0);

    uint balance = tokenBalanceForAddress[msg.sender][index];
    require(balance - amount >= 0);
    require(balance - amount <= balance);

    address erc20Token = tokens[index].tokenContract;
    ERC20Interface erc20 = ERC20Interface(erc20Token);
    uint total_exchange_balance = erc20.balanceOf(this);

    tokenBalanceForAddress[msg.sender][index] -= amount;
    WithdrawalToken(msg.sender, index, amount, now);
  }
  function getBalance(string symbolName) constant returns (uint) {
    uint8 index = getSymbolIndex(symbolName);
    require(index != 0);
    return tokenBalanceForAddress[msg.sender][index];
  }

  function depositEther() payable {
    require(balanceEthForAddress[msg.sender] + msg.value >= balanceEthForAddress[msg.sender]);
    balanceEthForAddress[msg.sender] += msg.value;
    DepositForEthReceived(msg.sender, msg.value, now);
  }
  function withdrawEther(uint amountInWei) {
    require(balanceEthForAddress[msg.sender] >= amountInWei);
    require(balanceEthForAddress[msg.sender] - amountInWei >= 0);
    require(balanceEthForAddress[msg.sender] - amountInWei <= balanceEthForAddress[msg.sender]);
    balanceEthForAddress[msg.sender] -= amountInWei;
    msg.sender.transfer(amountInWei);
    WithdrawalEth(msg.sender, amountInWei, now);
  }
  function getEthBalanceInWei() constant returns (uint) {
    return balanceEthForAddress[msg.sender];
  }
  function addToken(string symbolName, address erc20TokenAddress) onlyowner {
    require(!hasToken(symbolName));
    symbolNameIndex++;
    tokens[symbolNameIndex].symbolName = symbolName;
    tokens[symbolNameIndex].tokenContract = erc20TokenAddress;
    TokenAddedToSystem(symbolNameIndex, symbolName, now);
  }
  function hasToken(string symbolName) constant returns (bool) {
    return getSymbolIndex(symbolName) != 0;
  }
  function getSymbolIndex(string symbolName) internal returns (uint8) {
    for (uint8 i; i <= symbolNameIndex; i++) {
      if (stringsEqual(tokens[i].symbolName, symbolName)) {
        return i;
      }
    }
    return 0;
  }

  function stringsEqual(string storage _a, string memory _b) internal returns (bool) {
    bytes storage a = bytes(_a);
    bytes memory b = bytes(_b);
    if (a.length != b.length) {
      return false;
    }
    for (uint8 i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }


  function getBuyOrderBook(string symbolName) constant returns (uint[], uint[]) {
    uint[] memory pricesBuy = new uint[](1); 
    uint[] memory volumesBuy = new uint[](1);  
//    uint8 index = getSymbolIndex(symbolName);
    pricesBuy[0] = 100;
    volumesBuy[0] = 10;
    pricesBuy[1] = 100;
    volumesBuy[1] = 10;
    return (pricesBuy, volumesBuy);
//    return (new uint[](1), new uint[](1));
    //uint8 index = getSymbolIndex(symbolName);
    //require(index != 0);
    //tokens[index].buyBook;
    //mapping 
  }

  function getSellOrderBook(string symbolName) constant returns (uint[], uint[]) {
  }
  function buyToken(string symbolName, uint priceInWei, uint amount) {
//    uint8 index = getSymbolIndex(symbolName);
//    require(index != 0);
//    var book = tokens[index].buyBook;
//    var buy_to_add = Offer(amount, msg.sender);
//    var offers = book.offers_length;
//    if (book.offers_length == 0) {
//      book.offers[0] = buy_to_add;
//      book.higherPrice = priceInWei;
//      book.lowerPrice = priceInWei;
//      book.offers_key = 0;
//      book.offers_length = 1;
//      tokens[index].buyBook = book;
//      tokens[index].lowestBuyPrice = priceInWei;
//      tokens[index].amountBuyPrice++;
//    } else {
//      for (var i = 0; i < book.offers_length; i += 1) {
//        if (book.offers[i] 
//      }
//      while (book.offers_key <= 0
//    }
    //SellOrderFullfilled(
    //BuyOrderFullfilled(
    LimitBuyOrderCreated(0, msg.sender, priceInWei, 0);
  }

  function sellToken(string symbolName, uint priceInWei, uint amount) {
    //SellOrderFullfilled(
    //BuyOrderFullfilled(
    LimitSellOrderCreated(0, msg.sender, priceInWei, 0);
  }

  function cancelOrder(string symbolName, bool isSellOrder, uint priceInWei, uint offerKey) {
    //SellOrderCancelled(
    //BuyOrderCancelled(
  }

}
