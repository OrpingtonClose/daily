var BasicContract = artifacts.require("./Exchange.sol");
var FixedSupplyToken = artifacts.require("./FixedSupplyToken.sol");
//var Migrations = artifacts.require("./Migrations.sol");
//var owned = artifacts.require("./owned.sol");

module.exports = function(deployer) {
  deployer.deploy(FixedSupplyToken);
  deployer.deploy(BasicContract);
//  deployer.deploy(Migrations);
//  deployer.deploy(owned);
};


