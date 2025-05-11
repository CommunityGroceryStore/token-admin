import { createApp } from 'vue'
import '../src/assets/styles/monospaceweb-reset.css'
import '../src/assets/styles/monospaceweb-index.css'
import App from './App.vue'
import { WagmiPlugin } from '@wagmi/vue'
import { config } from '@/lib/wagmi/config'
import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'

const queryClient = new QueryClient()

createApp(App)
  .use(WagmiPlugin, { config })
  .use(VueQueryPlugin, { queryClient })
  .mount('#app')
