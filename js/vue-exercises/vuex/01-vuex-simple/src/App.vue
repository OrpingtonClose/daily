<template>
  <div id="app">
    <nav>
        <ul>
            <li>
                <router-link to="/STAR/LAMP">/STAR/LAMP</router-link>
                <router-link to="/LAMP/DIAM">/LAMP/DIAM</router-link>
            </li>
        </ul>
    </nav>
    <router-view/>
    <div class="balance">
        Your balance is:
        <ul>
            <li>{{$store.state.STAR}} stars</li>
            <li>{{$store.state.LAMP}} lamps</li>
            <li>{{$store.state.DIAM}} diamonds</li>
        </ul>    
    </div>
  </div>
</template>

<script>
export default {
  name: 'App'
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
