<template>
  <div id="app">
    <p>I have a secret message:</p>
    <p v-if="show" class="secret">{{message}}</p>
    <button v-else @click="show = true">Show Message</button>
  </div>
</template>

<script>
export default {
  data () {
    return {
      show: false,
      message: "very secret message here!"
    }
  }
}
</script>

<style>
  .secret {
    background-color: thistle;
  }
</style>
