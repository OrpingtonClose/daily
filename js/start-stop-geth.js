//https://www.npmjs.com/package/geth

var geth = require("geth");

var options = {
    networkid: "10101",
    port: 30303,
    rpcport: 7545
};

var customListener = {
    stdout(data) {
        process.stdout.write("I got a message!! " + data.toString());
    },
    stderr(data) {
        process.stdout.write("I got an error!! " + data.toString());
        if (data.toString().indexOf("Protocol Versions") > -1) {
            geth.trigger(null, geth.proc);
        }
    },
    close(code) {
        console.log("It's game over, man!  Game over!");
    }
}
let _proc;
let _web3;
//geth.start(options, customListener, function (err, proc) {
geth.start(options, function (err, proc) {
    if (err) return console.error(err);
    _proc = proc;
    console.log("=".repeat(20));
    console.log("launched");
    console.log("=".repeat(20));
    const Web3 = require("web3");
    _web3 = new Web3();
    _web3.setProvider(new Web3.providers.HttpProvider('http://localhost:7545'));
    ["api", "network", "ethereum"].forEach(prop => {
        console.log(`web3.version.${prop} ` + _web3.version[prop]);
    });
    geth.stop();
});

