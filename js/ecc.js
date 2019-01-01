var {sha3_512} = require("js-sha3");
var EC = require("elliptic").ec;
var ec = new EC("secp256k1");
var keys = ec.genKeyPair();
var privateKeyRaw = keys.getPrivate("hex");
var publicKeyRaw = keys.getPublic("hex");

function one() {
    var privateKey = ec.keyFromPrivate(privateKeyRaw, "hex");
    var publicKey = ec.keyFromPublic(publicKeyRaw, "hex");

    var message = "what is this";
    var msgHash = sha3_512(message);
    //https://davidederosa.com/basic-blockchain-programming/elliptic-curve-digital-signatures/
    //ECDSA signature, a simple pair of big numbers (r,s)
    var signature = privateKey.sign(msgHash);
    
    //ASN.1 is a data type declaration notation, like protocol buffers or thrift
    //X.690 is an ITU-T standard specifying several ASN.1 encoding formats (BER,CER,DER)
    //DER encoding is widely used to transfer digital certificates such as X.509.
    var sigDer = signature.toDER()
    console.log(publicKey.verify(msgHash, sigDer));
}

function two() {
    var publicKey = ec.keyFromPublic(keys.getPublic());
    var privateKey = ec.keyFromPrivate(keys.getPrivate());
    publicKey.getPublic().encode("hex");
    var message = "what is this";
    var msgHash = sha3_512(message);
    var signature = privateKey.sign(msgHash);
    publicKey.verify(msgHash, signature);
}

//https://github.com/indutny/elliptic/blob/master/test/ecdsa-test.js#L463
function eccRecovery() {
    var priv = ec.keyFromPrivate(privateKeyRaw, "hex");
    var msg = "abcde";
    var buf = [...Buffer.from(msg)];
    var msg = [1, 5, 477]
    var sig = priv.sign(msg);
    
    var pub = ec.keyFromPublic(publicKeyRaw, "hex");
    var recoveryParam = ec.getKeyRecoveryParam(msg, sig, pub)

    var recoveredPubKey = ec.recoverPubKey(msg, sig, recoveryParam);
    console.log(pub.getPublic().eq(recoveredPubKey));
}