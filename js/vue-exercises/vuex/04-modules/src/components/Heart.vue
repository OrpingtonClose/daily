<template>
    <div>
        <p>Loves: {{$store.state.heart.loves}}</p>
        <input v-model="partner" @input="love">
        <button @click="clear">Clear</button>
    </div>
</template>

<script>
export default {
  name: 'heart',
  data() {
      return {
          partner: undefined
      }
  },
  methods: {
      love() {
        this.$store.commit("love")
      },
      clear() {
        this.$store.commit("unlove")
        this.partner = undefined
      }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
</style>
