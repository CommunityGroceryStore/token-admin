<template>
  <div class="flex min-h-screen">
    <AdminPanel />
    <div class="p-6 w-full">
      <RouterView />
    </div>
  </div>
</template>

<style>
@import '@/style.css';
</style>

<script setup lang="ts">
import { RouterView } from 'vue-router'
import AdminPanel from './components/layout/AdminPanel.vue'
import { createAppKit } from '@reown/appkit/vue'
import { arbitrum, mainnet, sepolia } from '@reown/appkit/networks'
import { WagmiAdapter } from '@reown/appkit-adapter-wagmi'
import { networks } from '@/lib/wagmi/config'

// 1. Get projectId from https://cloud.reown.com
const projectId = 'cc48aa27f56fb12a67f6f04d1e0bc5db'

// 2. Create a metadata object - optional
const metadata = {
  name: 'erc20-admin',
  description: '',
  url: window.location.href,
  icons: ['https://assets.reown.com/reown-profile-pic.png']
}

// 3. Create Wagmi Adapter
const wagmiAdapter = new WagmiAdapter({
  networks,
  projectId
})

// 4. Create modal
createAppKit({
  adapters: [wagmiAdapter],
  networks: [mainnet, sepolia, arbitrum],
  metadata,
  projectId,
  features: {
    connectMethodsOrder: ['wallet', 'email', 'social']
  }
})
</script>
