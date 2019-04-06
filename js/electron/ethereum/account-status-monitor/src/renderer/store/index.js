import Vue from 'vue'
import Vuex from 'vuex'
import Web3 from 'web3'
import { createPersistedState, createSharedMutations } from 'vuex-electron'

//import modules from './modules'
Vue.use(Vuex)


export default new Vuex.Store({
    state: {
        web3: undefined
    },
    mutations: {
        SET_WEB3_INSTANCE(state, web3) {
            state.web3 = web3;
        }
    },
    actions: {
        herp(context) {
            //is this fired at all?
            console.log("herp ".repeat(20))
        },     
        setWeb3Instance(context, providerUrl) {
            //is this fired at all?
            console.log("setWeb3Instance".repeat(20))
            const web3Instance = new Web3(providerUrl);
            context.commit("SET_WEB3_INSTANCE", web3Instance);
        }
    },
    getters: {
        web3Info(state) {
            var result = {};
            var {web3} = state;
            if(!web3) {
                return JSON.stringify(state, null, 2);
            }
            if(!web3.defaultAccount){
                result["defaultAccount"] = web3.defaultAccount;
            }
            if(!web3.defaultBlock){
                result["defaultBlock"] = web3.defaultBlock;
            }
            if(!web3.defaultGas){
                result["defaultGas"] = web3.defaultGas;
            }
            if(!web3.defaultGasPrice){
                result["defaultGasPrice"] = web3.defaultGasPrice;
            }
            if(!web3.transactionBlockTimeout){
                result["transactionBlockTimeout"] = web3.transactionBlockTimeout;
            }
            if(!web3.transactionConfirmationBlocks){
                result["transactionConfirmationBlocks"] = web3.transactionConfirmationBlocks;
            }
            if(!web3.transactionPollingTimeout){
                result["transactionPollingTimeout"] = web3.transactionPollingTimeout;
            }
            if(!web3.currentProvider){
                result["currentProviderHost"] = web3.currentProvider.host;
            }
            if(!web3.version){
                result["web3Version"] = web3.version;
            }            
            return result;
        }
    },
//    modules,
    plugins: [
        createPersistedState(),
        createSharedMutations()
    ],
    strict: process.env.NODE_ENV !== 'production'
})
