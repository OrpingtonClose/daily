var {sha3_512} = require("js-sha3");
var EC = require("elliptic").ec;
var ec = new EC("secp256k1");
var key = ec.genKeyPair();

function one() {
    var key = ec.genKeyPair();

    var message = "what is this";
    var msgHash = sha3_512(message);
    var signature = key.sign(msgHash);

    console.log(key.verify(msgHash, signature.toDER()));
}

(function two() {
    var publicKey = ec.keyFromPublic(key.getPublic());
    var privateKey = ec.keyFromPrivate(key.getPrivate());
    publicKey.getPublic().encode("hex");
    var message = "what is this";
    var msgHash = sha3_512(message);
    var signature = privateKey.sign(msgHash);
    publicKey.verify(msgHash, signature);
})()