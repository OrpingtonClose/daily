pragma solidity ^0.4.13;

import "./owned.sol";
import "./FixedSupplyToken.sol";

contract Exchange is owned {
  struct Offer {
    uint amount;
    address who;
  }
  struct OrderBook {
    uint highestPrice;
    uint lowestPrice;
    mapping (uint => Offer) offers;
    uint offers_key;
    uint offers_length;
  }
  struct Token {
    address tokenContract;
    string symbolName;
    mapping (uint => OrderBook) buyBook;
    uint curBuyPrice;
    uint lowestBuyPrice;
    uint amountBuyPrices;

    mapping (uint => OrderBook) sellBook;
    uint curSellPrice;
    uint highestSellPrice;
    uint amountSellPrices;
  }

  mapping (uint8 => Token) tokens;
  uint8 symbolNameIndex;

  mapping (address => mapping (uint8 => uint)) tokenBalanceForAddress;
  mapping (address => uint) balanceEthForAddress;

  function depositEther() payable {
  }
  function withdrawEther(uint amountInWei) {
  }
  function getEthBalanceInWei() constant returns (uint) {
  }

  function addToken(string symbolName, address erc20TokenAddress) onlyowner {
    //if (hasToken(symbolName)) {
    //  throw;
    //}
    //symbolNameIndex += 1;
    //tokens[symbolNameIndex] = Token(erc20TokenAddress, symbolName);
    require(!hasToken(symbolName));
    symbolNameIndex++;
    tokens[symbolNameIndex].symbolName = symbolName;
    tokens[symbolNameIndex].tokenContract = erc20TokenAddress;
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
    return true;
  }

  function depositToken(string symbolName, uint amount) {
  }
  function withdrawToken(string symbolName, uint amount) {
  }
  function getBalance(string symbolName) constant returns (uint) {
  }

  function getBuyOrderBook(string symbolName) constant returns (uint[], uint[]) {
  }
  function getSellOrderBook(string symbolName) constant returns (uint[], uint[]) {
  }
  function buyToken(string symbolName, uint priceInWei, uint amount) {
  }
  function sellToken(string symbolName, uint priceInWei, uint amount) {
  }
  function cancelOrder(string symbolName, bool isSellOrder, uint priceInWei, uint offerKey) {
  }
}
