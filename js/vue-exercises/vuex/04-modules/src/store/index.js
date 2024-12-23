import Vue from 'vue'
import Vuex from 'vuex'
Vue.use(Vuex)

const heart = {
    state: {
        loves: undefined
    },
    mutations: {
        love(state, target) {
            state.loves = target
        },
        unlove(state) {
            state.loves = undefined
        }
    }
}

const leftLobe = {
    namespaced: true,
    state: {reason: true},
    mutations: {
        toggle (state) {
            state.reason = !state.reason
        }
    }
}

const rightLobe = {
    namespaced: true,
    state: {fantasy: true},
    mutations: {
        toggle (state) {
            state.fantasy = !state.fantasy
        }
    }
}

const brain = {
    modules: {
        left: leftLobe,
        right: rightLobe
    }
}

const store = new Vuex.Store({
    modules: {
        brain, heart
    }
})

export default store