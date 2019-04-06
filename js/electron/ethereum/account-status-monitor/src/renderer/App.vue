<template>
    <div id="app">
        <div>{{url()}}</div><br/>
      <ul>
          <li><router-link to="/" exact>Home 1</router-link></li>
          <li><router-link to="/home">Home 2</router-link></li>
      </ul>        
        <transition mode="out-in">
            <router-view></router-view>
        </transition>
    </div>
</template>

<script>
    export default {
        name: 'account-status-monitor',
        methods: {
            url() {
                return document.URL;
            }
        }
    }
</script>

<style>
  /* CSS */
</style>
