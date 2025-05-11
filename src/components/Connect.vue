<template>
  Current Chain: {{ currentChain?.name }}
  <br />
  Connect Wallet to continue
  <br />
  <button
    v-for="connector in connectors"
    @click="connect({ connector, chainId })"
  >
    {{ connector.name }}
  </button>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useConnect, useChainId, useChains } from '@wagmi/vue'

const chainId = useChainId()
const { connectors, connect } = useConnect()
const chains = useChains()
const currentChain = computed(() => {
  return chains.value.find((chain) => chain.id === chainId.value)
})
</script>
