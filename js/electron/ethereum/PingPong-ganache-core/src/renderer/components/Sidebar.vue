<template lang="pug">
    v-navigation-drawer(clipped, permanent, width="130px", style="max-height: 100vh;")
        v-list(two-line, subheader)
            template(v-for="(account, i) in accounts")
                puff
                    v-list-tile.pong-holder(:key="'owner' + i" v-if="owner === account.address", @click="$emit('new-owner', account.address)")
                        v-list-tile-avatar
                            identicon(:from="account.address")
                        v-list-tile-content
                            v-list-tile-title {{ account.address.slice(0, 10) }}
                            v-list-tile-sub-title pong-holder
                    v-list-tile(:key="'notowner' + i" v-if="owner !== account.address", @click="$emit('new-owner', account.address)")
                        v-list-tile-avatar
                            identicon(:from="account.address")
                        v-list-tile-content
                            v-list-tile-title {{ account.address.slice(0, 10) }}
                            v-list-tile-sub-title click to pass Pong here

</template>

<script>
  import './Puff';
  import Identicon from './Identicon';
  export default {
    name: 'sidebar',
    data() {
        return {
            show: true
        }
    },
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
    @import url(https://fonts.googleapis.com/css?family=Roboto:100,300,400,500,700,900|Material+Icons);
    .too_much_height {
        max-height: 100vh;
    }
    .pong-holder {
        background-color: red;
        font-weight: bold;
    }
    .fade-enter-active, .fade-leave-active {
        transition: opacity .5s;
        /* transition: background-color .5s; */
    }
    .fade-enter, .fade-leave-to /* .fade-leave-active below version 2.1.8 */ {
        /* background-color: white; */
        opacity: 0;
    }
   /* .v-enter {
        opacity: 0;
   }
    .v-enter-active {
        transition: opacity 2s;
    }
    .v-leave {
        opacity: 0;
        font-size: 0;
    }
    .v-leave-active {
        transition: opacity 2s;
        transition: font-size 2s;
    }     */
.myText {
 /* this clip-path creates a perfect match with the element */
  clip-path: polygon(0% 0%, 100% 0%, 100% 100%, 0% 100%);
}
.myTransition-enter-active, .myTransition-leave-active {
  transition: all .5s ease-out;
}
.myTransition-enter, .myTransition-leave-to {
  clip-path: polygon(0% 0%, 100% 0%, 100% 0%, 0% 0%);
  transform: translate(0%, 100%);
}

.fadeOne-enter-active, .fadeOne-leave-active {
  transition: all .5s ease-out;
}
.fadeOne-enter, .fadeOne-leave-to {
  clip-path: polygon(0% 0%, 100% 0%, 100% 0%, 0% 0%);
  transform: translate(0%, 100%);
}

.fadeTwo-enter-active, .fadeTwo-leave-active {
  transition: all .5s ease-out;
}
.fadeTwo-enter, .fadeTwo-leave-to {
  clip-path: polygon(0% 100%, 100% 100%, 0% 100%, 0% 100%);
  transform: translate(-100%, -100%);
}
</style>
