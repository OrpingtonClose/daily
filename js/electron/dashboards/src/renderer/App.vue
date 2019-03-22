
<template>
    <div>
        <v-toolbar>
            <v-toolbar-side-icon></v-toolbar-side-icon>
                <v-toolbar-title>Title</v-toolbar-title>
                <v-spacer></v-spacer>
                <v-toolbar-items>
                <v-btn flat>Link One</v-btn>
                <v-btn flat>Link Two</v-btn>
                <v-btn flat>Link Three</v-btn>
            </v-toolbar-items>
        </v-toolbar>          
        <ul>
            <li>,mmmmmmmmmmmmmmmmmmmm</li>
            <li>oooo</li>
            <li>cccc</li>
        </ul>
        <v-btn @click="alert()">Hello</v-btn>
    </div>
</template>
<!-- <template>
    <div id="app">
        <v-toolbar height="400px" app fixed>
            <v-toolbar-title>Title</v-toolbar-title>
            <v-toolbar-items class="hidden-sm-and-down">
                <v-btn flat to="/">Hello</v-btn>
                <v-btn flat to="/herp">Hello</v-btn>  
                <v-btn flat to="/new">Hello</v-btn>  
            </v-toolbar-items>
        </v-toolbar>
            <!-- <v-btn to="/">Hello</v-btn>
            <v-btn to="/herp">Hello</v-btn>  
            <v-btn to="/new">Hello</v-btn>  
            <!-- <router-view></router-view> 
    </div>
</template>
-->
<!--
<template>
    <v-app id="inspire">
        <v-navigation-drawer v-model="drawer" fixed app>
            <v-list dense>
                <v-list-tile @click="">
                <v-list-tile-action>
                    <v-icon>home</v-icon>
                </v-list-tile-action>
                <v-list-tile-content>
                    <v-list-tile-title>Home</v-list-tile-title>
                </v-list-tile-content>
                </v-list-tile>
                <v-list-tile @click="">
                <v-list-tile-action>
                    <v-icon>contact_mail</v-icon>
                </v-list-tile-action>
                <v-list-tile-content>
                    <v-list-tile-title>Contact</v-list-tile-title>
                </v-list-tile-content>
                </v-list-tile>
            </v-list>
        </v-navigation-drawer>
        
        <v-toolbar color="indigo" dark fixed app id="herpmerp">
            <div id="herpmerp">ddddddddddddddddddd</div>
        <v-toolbar-side-icon @click.stop="drawer = !drawer"></v-toolbar-side-icon>
        <v-toolbar-title>Application</v-toolbar-title>
        </v-toolbar>
        
        <v-content>
        <v-container fluid fill-height>
            <v-layout
            justify-center
            align-center
            >
            <v-flex text-xs-center>
                <v-tooltip left>
                <template v-slot:activator="{ on }">
                    <v-btn @click="drawer = !drawer">aaaaaaaaaaaaaaaaaaaa</v-btn>
                    <v-btn :href="source" icon large target="_blank" v-on="on">
                    <v-icon large>code</v-icon>
                    </v-btn>
                </template>
                <span>Source</span>
                </v-tooltip>
                <v-tooltip right>
                <template v-slot:activator="{ on }">
                    <v-btn icon large href="https://codepen.io/johnjleider/pen/rJdVMq" target="_blank" v-on="on">
                    <v-icon large>mdi-codepen</v-icon>
                    </v-btn>
                </template>
                <span>Codepen</span>
                </v-tooltip>
            </v-flex>
            </v-layout>
        </v-container>
        </v-content>
        <v-footer color="indigo">
        <span class="white--text">&copy; 2017</span>
        </v-footer>
    </v-app>
</template>
-->

<script>
    // import Vue from "vue";
    // import Vuetify from "vuetify";
    // Vue.use(Vuetify);
    export default {
        //name: 'dashboards',
        data: () => ({
            drawer: true
        }),    
        methods: {
            alert() {
                alert("herpmerp");
            }
        }
    }
</script>