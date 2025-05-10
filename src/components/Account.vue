<template>
  <div>
    Connected to <strong><code>{{ connector?.name }}</code></strong>
    on <strong><code>{{ currentChain?.name }}</code></strong>
  </div>
  <div>With address <strong><code>{{ address }}</code></strong></div>
  <div>and <strong><code>{{ balance }} $ETH</code></strong> available</div>
  <button @click="disconnect()">Disconnect</button>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useAccount, useChainId, useChains, useDisconnect } from '@wagmi/vue'
import { useEthersProvider } from '@/lib/wagmi/ethers'
import { ethers } from 'ethers'
import { useQuery } from '@tanstack/vue-query'

const { address, connector } = useAccount()
const { disconnect } = useDisconnect()
const chainId = useChainId()
const chains = useChains()
const currentChain = computed(() => {
  return chains.value.find((chain) => chain.id === chainId.value)
})

const { data: balance } = useQuery({
  queryKey: ['balance'],
  queryFn: async () => {
    const provider = useEthersProvider()
    if (!provider || !address.value) {
      return '0'
    }
    const balance = await provider.getBalance(address.value)

    return ethers.formatEther(balance)
  }
})
</script>
