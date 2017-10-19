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

  it( "should be able to deposit and withdraw ether to and from the exchange", function(  ) {
    var _instance;
    var amount_to_transfer;
    var declared_gas_cost;
    var balance_owner_start;
    var balance_owner_end;
    var balance_receiver_end;

    return exchange.deployed(  ).then( function( instance ) {
      _instance = instance;
      return web3.toWei( 1, "ether" );

    } ).then(  function(  to_transfer )  {
      amount_to_transfer = to_transfer;
      return web3.eth.getBalance( accounts[0] );

    } ).then( function( balance ) {
      balance_owner_start = balance;
      return _instance.depositEther( {from: accounts[0], value: amount_to_transfer} );

    } ).then( function( transaction_hash ) {
      declared_gas_cost = transaction_hash.receipt.cumulativeGasUsed.toString();
      return web3.eth.getBalance( accounts[0] );

    } ).then( function( balance ) {
      balance_owner_end = balance;
      return web3.eth.getBalance( accounts[1] );

    } ).then( function( balance ) {
      balance_receiver_end = balance;
      var new_balance_plus_transfer = balance_owner_end.plus( amount_to_transfer ); 
      var cost_of_gas = balance_owner_start.minus( new_balance_plus_transfer );
      var total_sent = balance_owner_end.minus(balance_owner_start);
      var digits_gas_cost = cost_of_gas.toString().length;
      var digits_to_append = digits_gas_cost - declared_gas_cost.length;
      var corrected_declared_gas_cost = declared_gas_cost + "0".repeat(digits_to_append);
      var new_balance_and_gas = balance_receiver_end.minus(Number(corrected_declared_gas_cost));
      var corrected_old_balance = balance_owner_end.plus(Number(corrected_declared_gas_cost));
      assert(new_balance_and_gas.equals(corrected_old_balance), new_balance_and_gas.toString() + " " + corrected_old_balance.toString());
    } );
  } );
} );
 
