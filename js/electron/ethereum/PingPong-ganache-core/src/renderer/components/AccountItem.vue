<template>
    <v-navigation-drawer permanent persistent width="130px">
        <v-list>
            <v-list-tile>
                <v-list-tile-content>
                    <v-list-tile-title>Accounts</v-list-tile-title>
                </v-list-tile-content>
            </v-list-tile>
        </v-list>
        <v-divider></v-divider>
        <v-list two-line subheader>                
            <transition-group name="fadeOne" mode="out-in">
            <template v-for="(account, i) in accounts">
                
                <!-- <v-list-tile class="pong-holder" @click="$emit('new-owner', account.address)"> -->
                    <v-list-tile :key="'herp' + i" @click="$emit('new-owner', account.address)">
                        <v-list-tile-avatar>
                            <identicon :from="account.address"></identicon>
                        </v-list-tile-avatar>
                        <v-list-tile-content>  
                            <!-- <transition name="fade" mode="out-in"> -->
                                <v-list-tile-title>{{ account.address.slice(0, 10) }}</v-list-tile-title>
                            <!-- </transition>                -->
                            
                                <!-- <v-list-tile-title v-show="owner === account.address">
                                    {{ account.address.slice(0, 10) }}
                                </v-list-tile-title> -->
                                <v-list-tile-sub-title class="myText" v-show="owner === account.address">
                                    pong-holder
                                </v-list-tile-sub-title>
                            <!-- </transition>                       -->
                        </v-list-tile-content>
                    </v-list-tile>
                
            </template>
            </transition-group>
        </v-list>
    </v-navigation-drawer>
</template>

<script>
  import Identicon from './Identicon';
  export default {
    name: 'sidebar',
    components: { Identicon },
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
</style>
