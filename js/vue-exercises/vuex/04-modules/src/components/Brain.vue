<template>
    <div>
        <img :class="{ off: !$store.state.brain.left.reason }"
            src="../assets/n8B6wuY.png"
            @click="left"/>
        <img :class="{ off: !$store.state.brain.right.fantasy }"
            src="../assets/4BbfVur.png"
            @click="right"/>
    </div>
</template>

<script>
export default {
  name: 'brain',
  methods: {
      left() {
        this.$store.commit("left/toggle")
      },
      right() {
        this.$store.commit("right/toggle")
      }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.off {
    filter: grayscale(100%)
}
</style>
