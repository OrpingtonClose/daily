<template lang="pug">
v-app(dark, standalone)
    sidebar(v-on:new-owner="setNewOwner", :owner="currentOwner", :accounts="accounts")    
    v-toolbar.darken-1(fixed,dark) 
        v-toolbar-title ping pong
    main
        v-container.pa-4(fluid,  align-content-center, style="min-height: calc(100vh - 64px - 56px);")
            v-toolbar(flat)
                v-list
                    v-list-tile
                        v-list-tile-title(class="title", style="overflow-y: hidden;") Ping Pong passes
            v-list
                v-list-tile(@click.prevent="", avatar, v-for="(event, i) in eventsPaginated", :key="i")
                    v-list-tile-action(@click.prevent="")
                        identicon(:from="event.from")
                    v-list-tile-content
                        v-list-tile-title 
                            v-container
                                v-layout(row wrap align-center, overflow-hidden)
                                    v-flex.text-xs-left from: {{event.from.slice(0, 10)}} 
                                    v-flex.text-xs-right to: {{event.to.slice(0, 10)}}    
                                    
                    v-list-tile-avatar
                        identicon(:from="event.to")
        .text-xs-center
            v-bottom-sheet(persistent, inset, vaue=true)
                v-list
                    v-pagination(v-model="page",:length="totalPages")     
        v-snackbar(v-model="snackbar", top)
            v-container(bg fill-height grid-list-md text-xs-center)
                v-layout(row wrap align-center)
                    v-flex new Pong Owner: {{whatHappened[whatHappened.length-1].to.slice(0, 10)}}   <identicon scale="2" :from="whatHappened[whatHappened.length-1].to" />
            //- .text-xs-center 
            
</template>

<script>    
  import SystemInformation from './LandingPage/SystemInformation'
  import Sidebar from './Sidebar'
  import Identicon from './Identicon'

  export default {
    name: 'landing-page',
    components: { SystemInformation, Sidebar, Identicon },
    computed: {
        eventCount() {
            return this.whatHappened.length;
        },
        totalPages() {
            return Math.ceil(this.whatHappened.length / this.eventsPerPage);
        },        
        eventsPaginated() {
            var start = (this.page - 1) * this.eventsPerPage;
            var end = start + this.eventsPerPage;
            return this.whatHappened.slice(start, end);
        }
    },
    methods: {
        setNewOwner(address) {
            var _this = this;
            _this.pingPong.methods.currentOwner().call().then(owner => {
                return _this.pingPong.methods.send(address).send({ from: owner });
            }).then(res => {
                return _this.pingPong.methods.currentOwner().call()
            }).then(newOwner=>{
                _this.currentOwner = newOwner;
            });
        },
        randomAddress() {
            return this.web3.accounts.create().address();
        }
    },
    data() {
        return {
            page: 1,
            eventsPerPage: 5,
            snackbar: false,
            web3: undefined,
            accounts: [],
            pingPong: undefined,
            currentOwner: undefined,
            whatHappened: []
        }
    },
    mounted() {
        //const blockies = require("./blockies");
        const Web3 = require("web3");
        const ganache = require("ganache-core");
        const privateKeys = [ "0x21d2bf4a063cb1709bb5439cfbbf808afe2a02ba4883eba2586642d4961bde3a",
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
        var balance = "0x"+ (100000000000000000000).toString(16);
        var options = {
            accounts: privateKeys.map(secretKey  => ({balance, secretKey}))
        }
        var provider = ganache.provider(options);
        this.web3 = new Web3(provider);
        this.accounts = privateKeys.map(pk => this.web3.eth.accounts.privateKeyToAccount(pk));
      
        var bytecode = '0x60806040526040518060400160405280600881526020017f50696e67506f6e670000000000000000000000000000000000000000000000008152506001908051906020019061004f92919061015b565b5034801561005c57600080fd5b50336000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055507f06b0e1597a64d4e56b112944958ac29dc7a0b334f224163c0afe2e54b390b76e60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff16604051808373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020018273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019250505060405180910390a1610200565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f1061019c57805160ff19168380011785556101ca565b828001600101855582156101ca579182015b828111156101c95782518255916020019190600101906101ae565b5b5090506101d791906101db565b5090565b6101fd91905b808211156101f95760008160009055506001016101e1565b5090565b90565b6103c58061020f6000396000f3fe608060405234801561001057600080fd5b50600436106100415760003560e01c806306fdde03146100465780633e58c58c146100c9578063b387ef921461010d575b600080fd5b61004e610157565b6040518080602001828103825283818151815260200191508051906020019080838360005b8381101561008e578082015181840152602081019050610073565b50505050905090810190601f1680156100bb5780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b61010b600480360360208110156100df57600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff1690602001909291905050506101f5565b005b610115610370565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b60018054600181600116156101000203166002900480601f0160208091040260200160405190810160405280929190818152602001828054600181600116156101000203166002900480156101ed5780601f106101c2576101008083540402835291602001916101ed565b820191906000526020600020905b8154815290600101906020018083116101d057829003601f168201915b505050505081565b3373ffffffffffffffffffffffffffffffffffffffff166000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff161461024e57600080fd5b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff169050816000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055507f06b0e1597a64d4e56b112944958ac29dc7a0b334f224163c0afe2e54b390b76e816000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff16604051808373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020018273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019250505060405180910390a15050565b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1690509056fea165627a7a723058209be0447657e7078ab1e557a14a529e6699ed10142e4af92a86484899c03fcade0029';
        var abi = [{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"who","type":"address"}],"name":"send","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"currentOwner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"from","type":"address"},{"indexed":false,"name":"to","type":"address"}],"name":"PongDone","type":"event"}];

        const pingPongContract = new this.web3.eth.Contract(abi);
        pingPongContract.deploy( {
            data: bytecode
        }).send({
            from: this.accounts[0].address,
            gas: 400000
        })
      .on('error', err=>{})
      .on('transactionHash', hash => {})
      .on('receipt', (receipt) => {})
      .on('confirmation', (confirmationNumber, receipt) => {})
      .then((newContractInstance) => { 
        var _this = this;
        console.log("LOADED".repeat(20));
        _this.pingPong = newContractInstance;
        _this.pingPong.methods.currentOwner().call().then(owner => {
            _this.currentOwner = owner;
        });
        _this.pingPong.events.PongDone({fromBlock:0, toBlock:'latest'}).on("data", data => {
            var process = item => {
                var {from, to} = item.returnValues;
                return {from, to};
            };

            var isAtLastPage = _this.page === Math.ceil(_this.whatHappened.length / _this.eventsPerPage); 

            if (Array.isArray(data)) {
                _this.whatHappened += data.map(process);
            } else {
                _this.whatHappened.push(process(data));
            }
            if (isAtLastPage) {
                _this.page = Math.ceil(_this.whatHappened.length / _this.eventsPerPage);
            }

            _this.snackbar = false;
            setTimeout(function(data) {
                _this.snackbar = true;
            }, 500);            
        });
      });
      
    }
  }
</script>

<style>
    @import url('https://fonts.googleapis.com/css?family=Source+Sans+Pro');
    .much_too_much_height {
        min-height: calc(100vh - 64px - 56px);
    }
</style>
