import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

const store = new Vuex.Store({
    state: {
        bitcoin: 600,
        rate: 1000
    },
    getters: {
        euro: state => state.bitcoin * state.rate,
        houses: (state, getters) => averageHousePrice => getters.euro / averageHousePrice
    }
});

export default store;