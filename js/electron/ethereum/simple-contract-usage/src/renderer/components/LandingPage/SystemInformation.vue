<template>
  <div>
    <div class="title">Information</div>
    <div class="items">
      <div class="item">
        <div class="name">Path:</div>
        <div class="value">{{ path }}</div>
      </div>
      <div class="item">
        <div class="name">Route Name:</div>
        <div class="value">{{ name }}</div>
      </div>
      <div class="item">
        <div class="name">Vue.js:</div>
        <div class="value">{{ vue }}</div>
      </div>
      <div class="item">
        <div class="name">Electron:</div>
        <div class="value">{{ electron }}</div>
      </div>
      <div class="item">
        <div class="name">Node:</div>
        <div class="value">{{ node }}</div>
      </div>
      <!-- <div class="item">
        <div class="name">Web3</div>
        <div class="value">{{ web3Props }}</div>
      </div> -->
      <div class="item" v-for="(account, i) in web3Props" :key="account">
        <!-- <div class="name">Account {{ i }}</div> -->
        <div class="value">{{ account }}</div>
      </div>
    </div>
  </div>
</template>

<script>
    var electron = require("electron");
    export default {
        data () {
            return {
                web3Props: undefined,
                electron: process.versions.electron,
                name: this.$route.name,
                node: process.versions.node,
                path: this.$route.path,
                platform: require('os').platform(),
                vue: require('vue/package.json').version
            }
        },
        mounted() {
            //electron.ipcRenderer.send("web3", "");
            this.web3Props = electron.ipcRenderer.sendSync("web3", "accounts")
            //console.log();
            //console.log(electron.ipcRenderer);
        }
    }
</script>

<style scoped>
  .title {
    color: #888;
    font-size: 18px;
    font-weight: initial;
    letter-spacing: .25px;
    margin-top: 10px;
  }

  .items { margin-top: 8px; }

  .item {
    display: flex;
    margin-bottom: 6px;
  }

  .item .name {
    color: #6a6a6a;
    margin-right: 6px;
  }

  .item .value {
    color: #35495e;
    font-weight: bold;
  }
</style>
