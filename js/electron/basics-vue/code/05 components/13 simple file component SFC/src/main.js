import Vue from 'vue'
import MyComponent from './MyComponent.vue'

new Vue({
  el: '#app',
  render: h => h("div", {}, [h(MyComponent), h(MyComponent)])
});
