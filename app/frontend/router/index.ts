import { createRouter, createWebHistory } from 'vue-router'

// To avoid the error:Uncaught ReferenceError: Cannot access 'router' before initialization
// HomeView is imported in the routes definition

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: () => import('../views/HomeView.vue')
    },
  ]
})

export default router
