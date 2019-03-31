import Vue from 'vue'
import axios from 'axios'

import App from './App'
import router from './router'

if (!process.env.IS_WEB) Vue.use(require('vue-electron'))
Vue.http = Vue.prototype.$http = axios
Vue.config.productionTip = false

import Vuetify from 'vuetify';
import 'vuetify/dist/vuetify.min.css';
import 'magic.css/magic.css';
Vue.use(Vuetify);

// import * as blockies from 'blockies';
// document.body.appendChild(blockies({
//     seed: 'randstring', // seed used to generate icon data, default: random
//     color: '#dfe',
//     bgcolor: '#aaa',
//     size: 15, 
//     scale: 3, 
//     spotcolor: '#000' 
// }));

/* eslint-disable no-new */
new Vue({
  components: { App },
  router,
  template: '<App/>'
}).$mount('#app')
