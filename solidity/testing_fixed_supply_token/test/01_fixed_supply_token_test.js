var fixed_supply_token = artifacts.require("./FixedSupplyToken.sol");

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
});
 
