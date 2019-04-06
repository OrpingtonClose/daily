import Vue from 'vue';
import Vuex from 'vuex';
import axios from 'axios';
const endpoint = '/comic/';

Vue.use(Vuex);

const store = new Vuex.Store({
    state: {
        currentPanel: undefined,
        currentImg: undefined,
        errorStack: []
    },
    mutations: {
        setPanel(state, num) {
            state.currentPanel = num;
        },
        setImg(state, img) {
            state.currentImg = img;
        },
        pushError(state, error) {
            state.errorStack.push(error);
        }
    },
    actions: {
        herp(context, message) {
            console.log("herpmerp".repeat(20))
        },
        goToLastPanel({commit}) {
            axios.get(endpoint).then(({data}) => {
                commit('setPanel', data.num);
                commit('setImg', data.img);
            }).catch(error=>{
                commit('pushError', error);
            });
        }
    }
});

export default store;