import Vue from 'vue'
//import 'material-design-icons-iconfont/dist/material-design-icon.css';
// import axios from 'axios'

import App from './App'
import router from './router'

if (!process.env.IS_WEB) Vue.use(require('vue-electron'))
Vue.http = Vue.prototype.$http = require("axios");
Vue.config.productionTip = false

import Vuetify from 'vuetify';
import 'vuetify/dist/vuetify.min.css';
import VueRouter from 'vue-router';

Vue.use(Vuetify);
Vue.use(VueRouter);
//vue.$options.components["App"] = App;

// console.log(["vue", "=".repeat(10), ...Object.keys(vue)])
// console.log(["vue.$options", "=".repeat(10), ...Object.keys(vue.$options)])
// console.log(["vue.$options.components", "=".repeat(10), ...Object.keys(vue.$options.components)])
/* eslint-disable no-new */

new Vue({
    render: h => h(App),
    // components: { App },
    router,
    // template: '<App/>'
}).$mount('#appanother')

// new Vue({
//     components: { App },
//     router,
//     template: '<App/>'
// }).$mount('#appanother')
// new Vue({
//     el: "#app"//,
//     //router
// })