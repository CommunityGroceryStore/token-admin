<template>
  <p>
    You are connected to <em>{{ currentChain?.name }}</em>
    using <em>{{ connector?.name }}</em>
    <br />
    with address <strong><code>{{ address }}</code></strong>
    <br />
    and <strong><code>{{ balance?.formatted }}</code></strong> Ethereum available.
  </p>
  <button @click="disconnect()">Disconnect</button>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import {
  useAccount,
  useBalance,
  useChainId,
  useChains,
  useDisconnect
} from '@wagmi/vue'

const { address, connector } = useAccount()
const { disconnect } = useDisconnect()
const chainId = useChainId()
const chains = useChains()
const currentChain = computed(() => {
  return chains.value.find((chain) => chain.id === chainId.value)
})
const { data: balance } = useBalance({ address })
</script>
