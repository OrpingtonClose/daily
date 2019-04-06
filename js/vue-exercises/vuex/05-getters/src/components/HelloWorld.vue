<template>
  <div>
      <h1>Balance</h1>
      <ul>
          <li>{{$store.state.bitcoin}}&#3647;</li>
          <li>{{$store.getters.euro}}&euro;</li>
          <li>{{$store.getters.houses(price)}} Houses</li>
      </ul>
      <input v-model="price">
      <!-- <pre>{{JSON.stringify($store.getters, null,2)}}</pre> -->
  </div>
</template>

<script>
export default {
  name: 'HelloWorld',
  data () {
    return {
      price: 150000
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h1, h2 {
  font-weight: normal;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
