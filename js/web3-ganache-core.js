//https://github.com/trufflesuite/ganache-core/blob/fd70a0679f1af830afe4178dcc707593c7205088/README.md
const Web3 = require("web3");
const ganache = require("ganache-core");
const _ = require("lodash");
var expect = require('chai').expect;
var should = require('chai').should();
var privateKeys = [   
    "0x21d2bf4a063cb1709bb5439cfbbf808afe2a02ba4883eba2586642d4961bde3a",
    "0x5a6a324cd932755ed07468f13baade4946fac8996f4627373f13f31534fee6fb",
    "0x21650cc4493535ea27a77a0740630562baf5b90d6558482098d820eb20ad0ee7",
    "0xbb2c1ac49965cb07fabe273616551dcd709253cd0762de7a7ace82b8d6fce080",
    "0xb4c65e114afa1cbdd156f24ce45a36bb77f535c7cb879950512e0114ef0bb5ef",
    "0xd6f44ec52b938f3ca9f30a3161e132205175a4affc8ca72c562e5e8337e5c570",
    "0xe60d3c55912c7b4733cb7e3cc2cb125b795db67f9e5b93f7b305c7a498022bab",
    "0xd5624db3981f73db5451003099c0d1b7ca5769085ddcd3cee244851b5eb86654",
    "0xcacbdaab312b0de0711a75d538fc07e980aedfc92691eecbb69f263d467148ef",
    "0xcbf871b44fcac9e63aef4d9554cc2bce7b5febd270dfb494b89fcd8dab7c3fba"
];

var options = {
    accounts: privateKeys.map(secretKey  => ({
        balance: "0x"+ parseInt(web3.utils.toWei("1000", "ether")).toString(16), 
        secretKey 
    }))
}
var a = (100).should.equal(10)
var web3 = new Web3(ganache.provider(options));

web3.eth.personal.getAccounts().then( accounts => {
    return Promise.all(accounts.map(account => {
        return web3.eth.getBalance(account).then(balance => {
            return web3.utils.fromWei(balance, "ether");
        });
    })).then(balances => {
        console.log(balances)
        return balances;
    })
}).then(ethBalances => {
    ethBalances.forEach(ethBalance => {
        ethBalance.should.equal("1000")
    });
    console.log(ethBalances)
}).catch(console.error);

//web3.eth.accounts.privateKeyToAccount("0x21d2bf4a063cb1709bb5439cfbbf808afe2a02ba4883eba2586642d4961bde3a");

var sending = web3.eth.accounts.privateKeyToAccount(privateKeys[0]);
var receiving = web3.eth.accounts.privateKeyToAccount(privateKeys[1]);

(async function() {
    var tx = {
        nonce: await web3.eth.getTransactionCount(sending.address),
        chainId: await web3.eth.net.getId(),
        to: receiving.address,
        value: web3.utils.toHex(web3.utils.toWei("0.001", "ether")),
        gas: web3.utils.toHex(2000),
        gasPrice: web3.utils.toHex(400)
    };
    var signedTx = await web3.eth.accounts.signTransaction(tx, sending.privateKey);
    web3.eth.sendSignedTransaction(signedTx.rawTransaction).on("receipt", console.log);
    await web3.currentProvider.sendPayload({
        jsonrpc: "2.0",
        method: "evm_mine",
        id: new Date().getTime()
    });
    //   console.log("block" + (await web3.eth.getBlock("latest")).number);
})()

web3.currentProvider.send({
    jsonrpc: "2.0",
    method: "evm_mine",
    id: 123
});

web3.currentProvider.send({
    jsonrpc: "2.0",
    method: "evm_mine",
    params: [new Date().getTime()],
    id: 333
});

var jsonrpc = '2.0'
var id = 0
var send = (method, params = []) =>
  web3.currentProvider.send({ id, jsonrpc, method, params })
var timeTravel = async seconds => {
  await send('evm_increaseTime', [seconds])
  await send('evm_mine')
}

timeTravel(0)

(async function mineSingleBlock() {
    let result = await web3.currentProvider.sendPayload({
      jsonrpc: "2.0",
      method: "evm_mine",
      id: new Date().getTime()
    });
//    assert.deepStrictEqual(result.result, "0x0");
})()

web3.eth.getBlock("latest").then(console.log)