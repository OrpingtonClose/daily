import Vue from 'vue'
Vue.component("puff", {
    functional: true,
    render: function (createElement, context) {
    var data = {
        props: {
            // "enter-active-class": "magictime puffIn",
            // "leave-active-class": "magictime puffOut",
            "enter-active-class": "magictime tinLeftIn",
            "leave-active-class": "magictime tinLeftOut",
            // "enter-active-class": "magictime slideLeft",
            // "leave-active-class": "magictime slideLeftReturn",                        
            "mode": "out-in"
        }
    }
    return createElement("transition", data, context.children)
    }
});