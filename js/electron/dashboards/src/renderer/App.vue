
<template>
    <div>
        <v-toolbar >
            <v-btn icon @click.stop="drawer = !drawer">
            <v-icon>menu</v-icon>
            </v-btn>
            <!-- <v-btn flat @click="$router.push({path:'/'})">One</v-btn> -->
            <!-- <v-toolbar-side-icon></v-toolbar-side-icon> -->
                <v-toolbar-title>Title</v-toolbar-title>
                <v-spacer></v-spacer>
                <v-toolbar-items>
                <!-- <router-link to="/"><v-btn flat>one</v-btn></router-link>
                <v-btn flat><router-link to="/herp">Two</router-link></v-btn>  
                <v-btn flat><router-link to="/new">Three</router-link></v-btn>                       -->
                <v-btn flat @click="$router.push({path:'/'})">One</v-btn>
                <v-btn flat @click="$router.push({path:'/herp'})">Two</v-btn>  
                <v-btn flat @click="$router.push({path:'/new'})">Three</v-btn>  
            </v-toolbar-items>
        </v-toolbar>
        <ul>
            <li>,mmmmmmmmmmmmmmmmmmmm</li>
            <li>oooo</li>
            <li>cccc</li>
        </ul>
        <v-btn @click="alert(Object.keys($router))">Hello</v-btn>
        <br/>
        <!-- <ul>
            <li><router-link to="/">one</router-link></li>
            <li><router-link to="/herp">Two</router-link></li>
            <li><router-link to="/new">Three</router-link></li>
        </ul> -->
        <router-view></router-view>
    </div>
</template>

<script>
// import Vue from 'vue'
//     import Vuetify from 'vuetify';
//     import 'vuetify/dist/vuetify.min.css';
//     import VueRouter from 'vue-router';
//     Vue.use(Vuetify);
//     Vue.use(VueRouter);
    export default {
        //name: 'dashboards',
        data: () => ({
            drawer: true
        }),    
        methods: {
            alert(m) {
                alert(m);
            }
        }
    }
</script>
<style>
   @import url(https://fonts.googleapis.com/css?family=Roboto:100,300,400,500,700,900|Material+Icons);
</style>