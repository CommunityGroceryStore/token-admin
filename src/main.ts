import { createApp } from 'vue'
import App from './App.vue'
import { createRouter, createWebHistory } from 'vue-router'
import Dashboard from './components/Dashboard.vue'
import { WagmiPlugin } from '@wagmi/vue'
import { config } from "@/lib/wagmi/config";
import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import DeployToken from './components/DeployToken.vue'

const queryClient = new QueryClient()

const router = createRouter({
    history: createWebHistory(),
    routes: [
      { path: '/', component: Dashboard },
      { path: '/deploy', component: DeployToken },
    ]
  })

createApp(App)
.use(router)
.use(WagmiPlugin, { config })
.use(VueQueryPlugin, { queryClient })
.mount('#app')
