import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)

export default new Router({
  routes: [{
        path: '/',
        name: 'landing-page',
        component: require('@/components/LandingPage').default
    },{
        path: '/herp',
        name: 'herp',
        component: require('@/components/test').default
    },{
        path: '/new',
        name: 'new',
        component: require('@/components/NewComp').default
    },{        
        path: '*',
        redirect: '/'
    }]
});
