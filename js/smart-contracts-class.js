var Web3 = require("web3");
var ganacheUi = "http://127.0.0.1:7545";
var ganacheCli = "http://127.0.0.1:8545";
var web3 = new Web3(ganacheUi);
web3.transactionConfirmationBlocks = 1
web3.transactionBlockTimeout = 5
web3.transactionPollingTimeout = 10
web3.clearSubscriptions
var privateKeys = [
    "0x0000000000000000000000000000000000000000000000000000000000000001",
    "0x0000000000000000000000000000000000000000000000000000000000000002",
    "0x0000000000000000000000000000000000000000000000000000000000000003",
    "0x0000000000000000000000000000000000000000000000000000000000000004",
    "0x0000000000000000000000000000000000000000000000000000000000000005"
];
var pe;
(async () => {
    var accounts = privateKeys.map(prv => web3.eth.accounts.privateKeyToAccount(prv));
    var initialAccounts = await web3.eth.getAccounts();
    accounts.forEach(account => {
        var to = account.address;
        pe = web3.eth.sendTransaction({
            from: initialAccounts[1], to, value: web3.utils.toWei("10", "ether")
        })
        //.once('transactionHash', function(hash){
            //console.log(hash);
        //    console.log('transactionHash');
        //    pe.off('error');
        //})//.then(console.log).catch(console.error)
        // .once('receipt', function(receipt){
        //     //console.log(receipt);
        //     console.log('receipt');
        // })
        .once('confirmation', function(confirmationNumber, receipt){ 
            console.log(confirmationNumber);
            console.log('confirmation');
        }).then(console.log)
//        await pe;
        //.on('error', console.error)
    });

    // await Promise.all(accounts.map(async account => {
    //     var to = account.address;
    //     return web3.eth.sendTransaction({
    //         from: initialAccounts[0], to, value: web3.utils.toWei("10", "ether")
    //     });
    // }))
    console.log("passed!")
    // for( account in accounts) {
    //     var to = account.address;
    //     await web3.eth.sendTransaction({
    //         from: initialAccounts[0], to, value: web3.utils.toWei("10", "ether")
    //     });
    // };
    // console.log( await Promise.all([accounts.map(a => a.address), initialAccounts].map(async accountGroup => {
    //     return await Promise.all(accountGroup.map(async address => {
    //         return {[`${address}`]: await web3.eth.getBalance(address)}
    //     }))
    // })));
})();


    // var from = initialAccounts[0];
    // await web3.personal.unlockAccount(from);
    // accounts.forEach(account => {
    //     var to = account.address;
    //     await web3.eth.sendTransaction({
    //         from, to, value: web3.toWei("10", "ether")
    //     });
    // });
    
    // console.log(initialAccounts.map(account=>account.address).map(web3.eth.getBalance).map(balance => balance.toString(10)));
    // accounts.forEach(account=> {
    //     console.log(await web3.eth.getBalance(account.address));
    // }); //.map(async address => {return await web3.eth.getBalance(address)}).map(balance => balance.toString(10))
    
    //console.log(accounts.map(account=>account.address).map(async address => {return await web3.eth.getBalance(address)}).map(balance => balance.toString(10)));
    // console.log(accounts);


(async () => {
    console.log( await Promise.all([accounts.map(a => a.address), initialAccounts].map(async accountGroup => {
        return await Promise.all(accountGroup.map(async address => {
            return {[`${address}`]: await web3.eth.getBalance(address)}
        }))
    })));
})()

web3.eth.getAccounts().then(accounts => {
    return accounts.reduce((biggest_account, new_account) => {
        if (biggest_account) {
            return new_account;
        }
        if (web3.eth.getBalance(new_account) > web3.eth.getBalance(biggest_account)) {
            return new_account;
        } else {
            return biggest_account;
        }
    })
}).then(console.log);

var from = web3.eth.accounts.reduce((biggest_account, new_account) => {
    if (biggest_account) {
        retuUirn new_account;
    }
    if (web3.eth.getBalance(new_account) > web3.eth.getBalance(biggest_account)) {
        return new_account;
    } else {
        return biggest_account;
    }
});