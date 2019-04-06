<template>
    <div class="hello">
        <h1>XKCD</h1>
        <img :src="currentImg">
    </div>
</template>

<script>
import {mapState} from 'vuex';
export default {
  name: 'hello',
  computed: mapState(['currentImg']),
  created() {
      this.$store.dispatch('herp', {message: "herpmerp"});
      this.$store.dispatch('goToLastPanel');
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
