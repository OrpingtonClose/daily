TOKEN=dcb9759b1cd5452f84115a66dbeea158
#https://api.infura.io/v3/jsonrpc/ropsten/eth_blockNumber?token=$TOKEN


geth attach "https://ropsten.infura.io/v3/$TOKEN"


curl -X POST \
-H "Content-Type: application/json" \
--data '{"jsonrpc": "2.0", "id": 1, "method": "eth_blockNumber", "params": []}' \
"https://ropsten.infura.io/v3/$TOKEN"

printf "%d\n" 0xfff
echo "ibase=16; fff"|bc

curl -X POST -H "Content-Type: application/json" \
--data '{"jsonrpc": "2.0", "id": 1, "method": "eth_blockNumber", "params": []}' \
"https://ropsten.infura.io/v3/$TOKEN" \
| jq'.result' -r | xargs -n 1 -I {} printf "%d\n" "{}"

~/ethereum-generate-wallet/ethereum-wallet-generator.sh

cat ~/ethereum-generate-wallet/requirements.txt

#https://ethtools.com/ropsten/tools/faucet/


curl -X POST -H "Content-Type: application/json" \
--data '{"jsonrpc": "2.0", "id": 1, "method": "eth_getBalance", "params": ["0x84FE12065D1902EcFEae2c90C940B2ce23b0eAE2", "latest"]}' \
"https://ropsten.infura.io/v3/$TOKEN" \
| jq '.result' -r | xargs -n 1 -I {} printf "%d\n" "{}"

curl  \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"eth_getBalance","params": ["0xc94770007dda54cF92009BFF0dE90c06F603a09f", "latest"],"id":1}'
    
sudo apt-get install solc

cat | solc --bin - <<EOF
contract OOO { function G() constant returns (string) {return "hello";} }
EOF

DATA=608060405234801561001057600080fd5b5061013f806100206000396000f300608060405260043610610041576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680636fecb62314610046575b600080fd5b34801561005257600080fd5b5061005b6100d6565b6040518080602001828103825283818151815260200191508051906020019080838360005b8381101561009b578082015181840152602081019050610080565b50505050905090810190601f1680156100c85780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b60606040805190810160405280600581526020017f68656c6c6f0000000000000000000000000000000000000000000000000000008152509050905600a165627a7a72305820121ecb7b55e924b2ac1543050f3ad344262525ef7461dd3d936c522f514f00c00029

curl -X POST --data '{"jsonrpc":"2.0","method":"eth_sendTransaction","params":[{ "from": "0x84FE12065D1902EcFEae2c90C940B2ce23b0eAE2", "gas": "0x776c0", "value": "0", "data": "0x608060405234801561001057600080fd5b5061013f806100206000396000f300608060405260043610610041576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680636fecb62314610046575b600080fd5b34801561005257600080fd5b5061005b6100d6565b6040518080602001828103825283818151815260200191508051906020019080838360005b8381101561009b578082015181840152602081019050610080565b50505050905090810190601f1680156100c85780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b60606040805190810160405280600581526020017f68656c6c6f0000000000000000000000000000000000000000000000000000008152509050905600a165627a7a72305820121ecb7b55e924b2ac1543050f3ad344262525ef7461dd3d936c522f514f00c00029"}],"id":1}' https://ropsten.infura.io/v3/$TOKEN

cat | solc --bin - <<EOF
pragma solidity ^0.4.4;
contract Token {
    function totalSupply() constant returns (uint256 supply) {}
    function balanceOf(address _owner) constant returns (uint256 balance) {}
    function transfer(address _to, uint256 _value) returns (bool success) {}
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
    function approve(address _spender, uint256 _value) returns (bool success) {}
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract StandardToken is Token {
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}

contract ERC20Token is StandardToken {
    function () {throw;}
    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'H1.0';
    function ERC20Token(
        ) {
        balances[msg.sender] = 1000;
        totalSupply = 1000;
        name = "excellent token";
        decimals = 0;
        symbol = "NOO";
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}
EOF
npm install web3
npm install abi-decoder
npm install ethereumjs-testrpc
npm install solc
npm install truffle-hdwallet-provider
npm install ethereumjs-wallet


#await web3.eth.getAccounts()
node
const fs = require("fs");
const abiDecoder = require('abi-decoder');
const Web3 = require('web3');
const solc = require('solc');
var WalletProvider = require('ethereumjs-wallet');

const input = fs.readFileSync('contracts/Token.sol');
const output = solc.compile(input.toString(), 1);
const bytecode = output.contracts[':Token'].bytecode;
const abi = JSON.parse(output.contracts[':Token'].interface);

var provider = new HDWalletProvider("dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd", "https://ropsten.infura.io/v3/$TOKEN");

#let provider = new Web3.providers.HttpProvider("https://ropsten.infura.io/v3/$TOKEN");

const web3 = new Web3(provider);
let Voting = new web3.eth.Contract(abi);

abiDecoder.addABI(abi);

const a = web3.eth.getAccounts().then(accounts => {
    accounts.forEach(account => {
      console.log(account)
    })
  });
  

var ethereumjs = require('ethereumjs-tx')
var wallet = require('ethereumjs-wallet')
var Web3 = require('web3')
var privateKey = Buffer.from("dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd", "hex");
var accountAddress = "0x84FE12065D1902EcFEae2c90C940B2ce23b0eAE2"
var web3 = new Web3(new Web3.providers.HttpProvider("https://ropsten.infura.io/v3/$TOKEN"));

var account = wallet.generate();
var accountAddress = account.getAddressString();
var privateKey = account.getPrivateKey();


web3.eth.getTransactionCount(accountAddress, function (err, nonce) {
    var data = "0x608060405234801561001057600080fd5b5061013f806100206000396000f300608060405260043610610041576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680636fecb62314610046575b600080fd5b34801561005257600080fd5b5061005b6100d6565b6040518080602001828103825283818151815260200191508051906020019080838360005b8381101561009b578082015181840152602081019050610080565b50505050905090810190601f1680156100c85780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b60606040805190810160405280600581526020017f68656c6c6f0000000000000000000000000000000000000000000000000000008152509050905600a165627a7a72305820121ecb7b55e924b2ac1543050f3ad344262525ef7461dd3d936c522f514f00c00029"
    var rawTx = {
      nonce: nonce,
      gasPrice: '0x00',
      gasLimit: '0x2FAF080',
      value: '0x00',
      data: data
    }
    var tx = new ethereumjs(rawTx);
 
    tx.sign(privateKey);
 
    var raw = '0x' + tx.serialize().toString('hex');
    web3.eth.sendRawTransaction(raw, function (txErr, transactionHash) {
      console.log("TX Hash: " + transactionHash);
      console.log("Error: " + txErr);
    });
  });



var solc = require('solc')
var ethereumjs = require('ethereumjs-tx')
var wallet = require('ethereumjs-wallet')
var Web3 = require('web3')

var input = 'contract x { function g() public const returns (string) {return "hello";} }'

var output = solc.compile(input, 1)
var contract;
for (var contractName in output.contracts) {
    contract = output.contracts[contractName];
    break;
}

var data = contract.bytecode

var account = wallet.fromPrivateKey(Buffer.from("privkey", "hex"));
var accountAddress = account.getAddressString();
var privateKey = account.getPrivateKey();
var web3 = new Web3(new Web3.providers.HttpProvider("https://ropsten.infura.io/v3/$TOKEN"));

console.log(data)
var recit = "0x3ce024cac97bd12679bb9557c4afcb57053c70b3de87e3f97baf238bd9e41233"
web3.eth.getTransactionCount(accountAddress, function (err, nonce) {
//    console.log("0x" + data)
var data = "0x2345" + data
var rawTx = {
    nonce: nonce,
    gasPrice: web3.utils.toHex(2 * 1e9),
    gasLimit: web3.utils.toHex(210000),
    value: '0x00',
    data: data
}
var tx = new ethereumjs(rawTx);

tx.sign(privateKey);

var raw = '0x' + tx.serialize().toString('hex');
web3.eth.sendSignedTransaction(raw, function (txErr, transactionHash) {
    console.log("TX Hash: " + transactionHash);
    recit = "0x3ce024cac97bd12679bb9557c4afcb57053c70b3de87e3f97baf238bd9e41233"
    console.log("Error: " + txErr);
});
});
var addr 
web3.eth.getTransactionReceipt(recit, function(err, ok) { 
    addr = ok.contractAddress
})
addr
var deployed = new web3.eth.Contract(JSON.parse(contract.interface), addr)
deployed.methods

  deployed.methods.g().call(, function(err, ok) { console.log(ok)})
  deployed.methods.g  
  //var inputABI = [{"constant":false,"inputs":[],"name":"hello","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"}]
  
  

var myContract = new web3.eth.contract(inputABI)





web3.eth.getTransactionCount(accountAddress, function (err, nonce) {
    //    console.log("0x" + data)
    var data = "0x2345" + data
    var rawTx = {
        nonce: nonce,
        gasPrice: web3.utils.toHex(2 * 1e9),
        gasLimit: web3.utils.toHex(210000),
        value: '0x00',
        data: data
    }
    var tx = new ethereumjs(rawTx);
    
    tx.sign(privateKey);
    
    var raw = '0x' + tx.serialize().toString('hex');
    web3.eth.sendSignedTransaction(raw, function (txErr, transactionHash) {
        console.log("TX Hash: " + transactionHash);
        recit = "0x3ce024cac97bd12679bb9557c4afcb57053c70b3de87e3f97baf238bd9e41233"
        console.log("Error: " + txErr);
    });