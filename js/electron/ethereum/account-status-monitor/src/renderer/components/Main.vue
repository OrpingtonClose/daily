<template>
  <div>
    <v-layout row>
        <v-flex xs12 sm6 offset-sm3>
            <!-- <pre>
                {{JSON.stringify($store.getters, null, 2)}}
            </pre> -->
        <v-card>
            <v-toolbar color="cyan" dark>
            <v-toolbar-side-icon></v-toolbar-side-icon>
            <v-toolbar-title>Inbox</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-btn icon>
                <v-icon>search</v-icon>
            </v-btn>
            </v-toolbar>
            <v-list two-line>
            <template v-for="(item, index) in items">
                <v-subheader
                v-if="item.header"
                :key="item.header"
                >
                {{ item.header }}
                </v-subheader>

                <v-divider
                v-else-if="item.divider"
                :key="index"
                :inset="item.inset"
                ></v-divider>

                <v-list-tile
                v-else
                :key="item.title"
                avatar
                @click=""
                >
                <v-list-tile-avatar>
                    <img :src="item.avatar">
                </v-list-tile-avatar>

                <v-list-tile-content>
                    <v-list-tile-title v-html="item.title"></v-list-tile-title>
                    <v-list-tile-sub-title v-html="item.subtitle"></v-list-tile-sub-title>
                </v-list-tile-content>
                </v-list-tile>
            </template>
            </v-list>
        </v-card>
        </v-flex>
    </v-layout>      
  </div>
</template>

<script>
//  import {mapGetters} from 'vuex';
//  import store from '../store'
  export default {
    name: 'main',
    methods: {
      open (link) {
        this.$electron.shell.openExternal(link)
      }
    },
    data () {
      return {
        items: [
          { header: 'Today' },
          {
            avatar: 'https://cdn.vuetifyjs.com/images/lists/1.jpg',
            title: 'Brunch this weekend?',
            subtitle: "<span class='text--primary'>Ali Connors</span> &mdash; I'll be in your neighborhood doing errands this weekend. Do you want to hang out?"
          },
          { divider: true, inset: true },
          {
            avatar: 'https://cdn.vuetifyjs.com/images/lists/2.jpg',
            title: 'Summer BBQ <span class="grey--text text--lighten-1">4</span>',
            subtitle: "<span class='text--primary'>to Alex, Scott, Jennifer</span> &mdash; Wish I could come, but I'm out of town this weekend."
          },
          { divider: true, inset: true },
          {
            avatar: 'https://cdn.vuetifyjs.com/images/lists/3.jpg',
            title: 'Oui oui',
            subtitle: "<span class='text--primary'>Sandra Adams</span> &mdash; Do you have Paris recommendations? Have you ever been?"
          }
        ]
      }
    },
    // computed: {
    //     ...mapGetters(['web3Info'])
    // },
    mounted() {
        //console.log(JSON.stringify(Object.keys(this.$store), null, 2))
        var providerUrl = "http://127.0.0.1:7545";
        console.log("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk")
        // store.dispatch('herp');
        // store.dispatch('setWeb3Instance', {providerUrl});
        // Window.s = store
    }
  }
</script>

<style>
  @import url('https://fonts.googleapis.com/css?family=Source+Sans+Pro');
  @import url(https://fonts.googleapis.com/css?family=Roboto:100,300,400,500,700,900|Material+Icons);
</style>
