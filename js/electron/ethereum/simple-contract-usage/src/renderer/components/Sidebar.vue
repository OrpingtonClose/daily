<template>
    <v-navigation-drawer app persistent width="130px">
        <v-list>
            <v-list-tile>
                <v-list-tile-content>
                    <v-list-tile-title>Accounts</v-list-tile-title>
                </v-list-tile-content>
            </v-list-tile>
        </v-list>
        <v-divider></v-divider>
        <v-list>    
            <v-list-tile :class="owner === account.address ? 'pong-holder' : ''" 
                         v-for="(account, i) in accounts" 
                         :key="i" 
                         @click="$emit('new-owner', account.address)">            
                <v-list-tile-content>
                    <v-list-tile-title>{{ account.address.slice(0, 10) }}</v-list-tile-title>
                </v-list-tile-content>
            </v-list-tile>
        </v-list>
    </v-navigation-drawer>
</template>

<script>
  export default {
    name: 'sidebar',
    props: {
        accounts: Array,
        owner: String
    },
    methods: {
        newOwnerChosen() {
            console.log("emitted");
            this.$emit('new-owner', account.address);
        }
    }
  }
</script>

<style scope>
   @import url(https://fonts.googleapis.com/css?family=Roboto:100,300,400,500,700,900|Material+Icons);
   .pong-holder {
       background-color: red
   }
</style>
