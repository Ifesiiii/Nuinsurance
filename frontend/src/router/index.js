import { createRouter, createWebHistory } from 'vue-router'
import ProductList from '../views/ProductList.vue'
import ProductDetails from '../views/ProductDetails.vue'
import RequestTracking from '../views/RequestTracking.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      redirect: '/products',
    },
    {
      path: '/products',
      name: 'products',
      component: ProductList,
    },
    {
      path: '/products/:id',
      name: 'product-details',
      component: ProductDetails,
    },
    {
      path: '/requests/:token',
      name: 'request-tracking',
      component: RequestTracking,
    },
  ],
  scrollBehavior() {
    return { top: 0 }
  },
})

export default router