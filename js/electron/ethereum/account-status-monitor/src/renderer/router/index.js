import Vue from 'vue'
import Router from 'vue-router'
import LandingPage from '@/components/LandingPage'
import Main from '@/components/Main'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
    //   name: 'landing-page',
      component: LandingPage
    },
    {
      path: '/home',
    //   name: 'main',
      component: Main
    },    
    // {
    //   path: '*',
    //   redirect: '/'
    // }
  ]
})
