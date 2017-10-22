var fixed_supply_token = artifacts.require("./FixedSupplyToken.sol");
var exchange = artifacts.require("./Exchange.sol");

contract('MyToken', function(accounts) {
  it("adds to numbers together", function() {
    assert.equal(2, 2);
  });

  it("first account should have all the tokens", function() {
    var _totalSupply;
    var myTokenInstance;
    return fixed_supply_token.deployed().then(function(instance) {
      myTokenInstance = instance;
      return myTokenInstance.totalSupply.call();
    }).then(function(totalSupply) {
      _totalSupply = totalSupply;
      return myTokenInstance.balanceOf(accounts[0]);
    }).then(function(balanceAccountOwner) {
      assert.equal(balanceAccountOwner.toNumber(), _totalSupply.toNumber(), "Total Amount of tokens is owned by owner");
    });
  });

  it("second account exists", function() {
    assert(accounts.length > 1, "more than one account was found");
  });

  it("second account has no tokens", function() {
    var _instance;
    return fixed_supply_token.deployed().then(function(instance) {
      _instance = instance; 
       return _instance.balanceOf(accounts[1]);
    }).then(function(balance) {
      assert.equal(balance.toNumber(), 0, "no amount of token is owned by second account");
    });
  });

  it("are payments being sent correctly between accounts", function() {
    var _instance;
    var _balance;
    var _acc1_start;
    var _acc1_end;
    var _acc2_start;
    var _acc2_end;

    return fixed_supply_token.deployed().then(function(instance) {
      _instance = instance;
      return _instance.balanceOf.call(accounts[0]);
    }).then(function(balance) {
      _acc1_start = balance.toNumber();
      return _instance.balanceOf.call(accounts[1]);
    }).then(function(balance) {
      _acc2_start = balance.toNumber();
      return _instance.transfer(accounts[1], 100, {from: accounts[0]});
    }).then(function(what_is_this) {
      return _instance.balanceOf.call(accounts[0]);
    }).then(function(balance) {
      _acc1_end = balance.toNumber();
      return _instance.balanceOf.call(accounts[1]);
    }).then(function(balance) {
      _acc2_end = balance.toNumber();
      assert.equal(_acc1_start, _acc1_end + 100, "first account change in balance");
      assert.equal(_acc2_start, _acc2_end - 100, "second account change in balance");
      //assert(_balance == 10000, "one wei was sent " + _balance + " " + balance_zero);
      //assert(_instance.getBalance().toNumber(), 10000, "one wei was sent");
    });
  });

  it("should be able to send all coins from one account and back again without losing anything", function() {
    var _instance;
    var _account_owner = accounts[0];
    var _account_not_owner = accounts[1];
    var _owner_starting_balance;
    return fixed_supply_token.deployed().then(function(instance) {
      _instance = instance;
      return _instance.balanceOf.call(_account_owner);
    }).then(function(balance_owner) {
      _owner_starting_balance = balance_owner;
      return _instance.transfer(_account_not_owner, _owner_starting_balance, {from: _account_owner});
    }).then(function(receipt) {
      return _instance.transfer(_account_owner, _owner_starting_balance, {from: _account_not_owner});
    }).then(function(receipt) {
      return _instance.balanceOf.call(_account_owner);
    }).then(function(owner_balance_after_exchange) {
      assert.equal(owner_balance_after_exchange.toNumber(), _owner_starting_balance.toNumber());
    });
  });
 
  it("should be able to deposit ether", function() {
    var _instance;
    return fixed_supply_token.deployed().then(function(instance) {
      _instance = instance;
      return _instance.send(web3.toWei(1, "ether"), {from: accounts[0]});
    }).then(function(receipt) {
      return web3.eth.getBalance(_instance.address);
    }).then(function(balance) {
      assert.equal(balance.toNumber(), web3.toWei(1, "ether"));
    });
  });

  it( "should be able to deposit ether to and from the exchange", function(  ) {
    var _instance;
    var amount_to_transfer;
    var declared_gas_cost;
    var balance_owner_start;
    var balance_owner_end;
    var balance_receiver_start;
    var balance_receiver_end;

    return exchange.deployed(  ).then( function( instance ) {
      _instance = instance;
      return {
        balance_owner_start: web3.eth.getBalance( accounts[0] ), 
        balance_receiver_start: web3.eth.getBalance( _instance.address ),
        amount_to_transfer: web3.toWei( 10, "ether" ),
      }
    } ).then( function( vals ) {
      balance_owner_start = vals.balance_owner_start;
      balance_receiver_start = vals.balance_receiver_start;
      amount_to_transfer = vals.amount_to_transfer;
      return _instance.depositEther( {from: accounts[0], value: amount_to_transfer} );

    } ).then( function( transaction_hash ) {
      declared_gas_cost = transaction_hash.receipt.cumulativeGasUsed.toString();
      return {
        balance_owner_end: web3.eth.getBalance( accounts[0] ),
        balance_receiver_end: web3.eth.getBalance( _instance.address ),
      }
    } ).then( function( vals ) {
      balance_owner_end = vals.balance_owner_end;
      balance_receiver_end = vals.balance_receiver_end;
      var balance_received = balance_receiver_end.minus(balance_receiver_start);
      assert(balance_received.eq(amount_to_transfer), "the amount received must match");
      var total_spent = balance_owner_start.minus(balance_owner_end);
      var cost_of_gas = total_spent.minus(amount_to_transfer);
      var digits_gas_cost = cost_of_gas.toString().length;
      var digits_to_append = digits_gas_cost - declared_gas_cost.length;
      var corrected_declared_gas_cost = declared_gas_cost + "0".repeat(digits_to_append);
      assert(cost_of_gas.eq(corrected_declared_gas_cost), cost_of_gas.toString() + " " + corrected_declared_gas_cost.toString() + " the declared and actual cost of sending the transaction should match");
    });
  });

  it( "should be able to withdraw ether to and from the exchange", function() {
    var _instance;
    var amount_to_return;
    var declared_gas_cost_return;
    var balance_owner_end;
    var balance_owner_return;
    var balance_receiver_end;
    var balance_receiver_return;

    return exchange.deployed(  ).then( function( instance ) {
      _instance = instance;
      return {
        balance_owner_end: web3.eth.getBalance( accounts[0] ), 
        balance_receiver_end: web3.eth.getBalance( _instance.address ),
        amount_to_return: web3.toWei( 5, "ether" ),
      }
    } ).then( function( vals ) {
      balance_owner_end = vals.balance_owner_end;
      balance_receiver_end = vals.balance_receiver_end;
      amount_to_return = vals.amount_to_return;
      return _instance.withdrawEther( amount_to_return, {from: accounts[0]} );
    } ).then(function(transaction) {
      declared_gas_cost_return = transaction.receipt.cumulativeGasUsed;
      return {
        balance_owner_returned: web3.eth.getBalance( accounts[0] ),
        balance_receiver_returned: web3.eth.getBalance( _instance.address ),
      };
    }).then(function(balances) {
      balance_owner_returned = balances.balance_owner_returned;
      balance_receiver_returned = balances.balance_receiver_returned;
      var balance_change_for_owner = balance_owner_returned.minus(balance_owner_end);
      assert(balance_change_for_owner.lt(amount_to_return) && balance_change_for_owner.gt(0), 
                  "owner start: " + balance_owner_end.toString() +
                  " owner end: " + balance_owner_returned.toString() +
                  " change: " + balance_change_for_owner.toString());
      var balance_returned = balance_receiver_end.minus(balance_receiver_returned);
      assert(balance_returned.equals(amount_to_return), 
             "to return :" + amount_to_return.toString() + 
             " returned :" + balance_returned.toString() +
             " contract at start :" + balance_receiver_end.toString() +
             " at end   :" + balance_receiver_returned.toString());
      var total_spent = balance_owner_returned.minus(balance_owner_end);
      var cost_of_gas = total_spent.minus(amount_to_return).mul(-1);
      var digits_gas_cost = cost_of_gas.toString().length;
      var digits_to_append = digits_gas_cost - declared_gas_cost_return.toString().length;
      var corrected_declared_gas_cost = declared_gas_cost_return + "0".repeat(digits_to_append);
      assert(cost_of_gas.eq(corrected_declared_gas_cost), 
             cost_of_gas.toString() + " " + 
             corrected_declared_gas_cost.toString() + 
             " the declared and actual cost of sending the transaction should match");
    });
  });

  it("checking ether balance of an account nobody transfer anything to should return zero", function() {
    var _instance;
    return exchange.deployed().then(function(instance) {
      _instance = instance;
      return _instance.getEthBalanceInWei({from: accounts[accounts.length-1]});
    }).then(function(balance) {
      assert(balance.equals(0), "untransfered account has balance of " + balance.toString());
    });
  });

  it("should show the balance of accounts", function() {
    var _instance;
    var value_sent = web3.toWei(2, "ether");
    return exchange.deployed().then(function(instance) {
      _instance = instance;
      return _instance.depositEther({from: accounts[3], value: value_sent});
    }).then(function(transaction) {
      return _instance.getEthBalanceInWei({from: accounts[3]});
    }).then(function(balance) {
      assert(balance.equals(value_sent), "balance is: " + balance.toString() + " should be " + value_sent.toString());
    });
  });

  it("should be able to add tokens", function() {
    var _exchange;
    var _token;
    return exchange.deployed().then(function(instance) {
      _exchange = instance;
      return fixed_supply_token.deployed();
    }).then(function(instance) {
      _token = instance;
      return _exchange.addToken("FIXED", _token.address);
    }).then(function(transaction) {
      assert(transaction.logs[0].event === "TokenAddedToSystem", "Event is to be emmited");
      return _exchange.hasToken("FIXED");
    }).then(function(has_token) {
      assert(has_token, "token was added");
      return _exchange.hasToken("not added");
    }).then(function(has_token) {
      assert(!has_token, "not added token was not present");
    });
  });      

  it("should be able to deposit tokens", function() {
    var _token;
    var _exchange;
    return fixed_supply_token.deployed().then(function(instance) {
      _token = instance;
      return exchange.deployed();
    }).then(function(instance) {
      _exchange = instance;
      return _token.approve(_exchange.address, 10);
    }).then(function(transaction) {
      return _exchange.depositToken("FIXED", 10, {from: accounts[0]});
    }).then(function(transaction) {
      return _exchange.getBalance.call("FIXED", {from: accounts[0]});
    }).then(function(balance) {
      assert(balance.eq(10), "the balance deposited must show for the account");
      return _token.balanceOf.call(_exchange.address);
    }).then(function(balance) {
      assert(balance.eq(10), "the balance must be owned by the contract");
    });
  });

  it("should be able to withdraw tokens", function() {
    var _token;
    var _exchange;
    var initial_balance;
    return fixed_supply_token.deployed().then(function(instance) {
      _token = instance;
      return exchange.deployed();
    }).then(function(instance) {
      _exchange = instance;
      return _exchange.getBalance.call("FIXED", {from: accounts[0]});
    }).then(function(balance) {
      initial_balance = balance;
      return _token.balanceOf(_exchange.address);
    }).then(function(balance) {
      assert(balance.eq(initial_balance), "the balance of the token for the exchange is all for the initial user");
      return _exchange.withdrawToken("FIXED", initial_balance);
    }).then(function(transaction) {
      return _exchange.getBalance("FIXED", {from: accounts[0]});
    }).then(function(balance) {
      assert(balance.eq(0), "after withdrawal, the exchange is to have no tokens");
      return _token.balanceOf(_exchange.address);
    }).then(function(balance) {
      assert(balance.eq(initial_balance), "after withdrawal, the owner is to have all tokens");
    });
  });

  it("should be able to add buy orders", function() {
    var _exchange;
    return exchange.deployed().then(function(instance) {
      _exchange = instance;
      return _exchange.buyToken("FIXED", 100, 10);
    }).then(function(transaction){
      assert(transaction.logs[0].event === "LimitBuyOrderCreated", "Event is to be emmited");
      return _exchange.getBuyOrderBook("FIXED");
    }).then(function(ret){
      var prices = ret[0];
      var volumes = ret[1];
      console.log("=====================");
      console.log(prices);
      console.log(volumes);
      assert(prices[0].toNumber() === 100 && volumes[0].toNumber() === 10, "the buy order made must show up");
      return _exchange.buyToken("FIXED", 90, 10);
    }).then(function(transaction){
      return _exchange.getBuyOrderBook("FIXED");
    }).then(function(prices, volumes){
      assert(prices[0] === 90 && volumes[0] === 10, "the additional buy order made must show up");
      console.log("========================");
      return _exchange.cancelOrder("FIXED", false, 90, 0);
    }).then(function(transaction){
      assert(transaction.logs[0].event === "BuyOrderCancelled", "BuyOrderCancelled Event is to be emmited");
      return _exchange.cancelOrder("FIXED", false, 100, 0);
    }).then(function(transaction){
      assert(transaction.logs[0].event === "BuyOrderCancelled", "another BuyOrderCancelled Event is to be emmited");
      return _exchange.getBuyOrderBook("FIXED");
    }).then(function(prices, volumes){
      assert(prices.length === 0 && volumes.length === 0, "all orders are supposed to be cancelled");
    });
  });

  it("should be able to add sell orders", function() {
    var _exchange;
    return exchange.deployed().then(function(instance) {
      _exchange = instance;
      return _exchange.sellToken("FIXED", 90, 10);
    }).then(function(transaction){
      assert(transaction.logs[0].event === "LimitSellOrderCreated", "Event is to be emmited");
      return _exchange.getSellOrderBook("FIXED");
    }).then(function(prices, volumes){
      assert(prices[0] === 90 && volumes[0] === 10, "the sell order made must show up");
      return _exchange.sellToken("FIXED", 100, 10);
    }).then(function(transaction){
      return _exchange.getSellOrderBook("FIXED");
    }).then(function(prices, volumes){
      assert(prices[0] === 100 && volumes[0] === 10, "the additional sell order made must show up");
      return _exchange.cancelOrder("FIXED", true, 100, 0);
    }).then(function(transaction){
      assert(transaction.logs[0].event === "SellOrderCancelled", "SellOrderCancelled Event is to be emmited");
      return _exchange.cancelOrder("FIXED", true, 90, 0);
    }).then(function(transaction){
      assert(transaction.logs[0].event === "SellOrderCancelled", "another SellOrderCancelled Event is to be emmited");
      return _exchange.getSellOrderBook("FIXED");
    }).then(function(prices, volumes){
      assert(prices.length === 0 && volumes.length === 0, "all orders are supposed to be cancelled");
    });
  });

/*
  //how to test for exceptions
  it("checking ether balance of an account nobody transfer anything to should return zero", function() {
    var c = _exchange.deployed().then(function(instance) {
      return instance.withdrawEther(-1, {from: accounts[0]});
    });
    console.dir(c);
    return c;
  });
*/
});
 
