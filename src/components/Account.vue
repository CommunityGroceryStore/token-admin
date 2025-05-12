<template>
  <p>
    You are connected to <em>{{ currentChain?.name }}</em>
    using <em>{{ connector?.name }}</em>.
  </p>
  <p>
    You are connected with address <strong><code>{{ address }}</code></strong>.
  </p>
  <p v-if="balance">
    You have <strong><code>{{
      (
        balance.value / 1_000_000_000_000_000_000n
      ).toLocaleString(undefined, { minimumFractionDigits: 2 })
    }}</code></strong>
    Ethereum available.
  </p>
  <p v-if="userTokenBalance">
    You have
    <strong><code>{{
      (
        userTokenBalance / 1_000_000_000_000_000_000n
      ).toLocaleString(undefined, { minimumFractionDigits: 2 })
    }}</code></strong>
    $CGS Tokens available.
  </p>
  <button @click="disconnect()">Disconnect</button>
  <button
    v-if="chainId === localhost.id"
    @click="resetLocalDevDeployment()"
  >‼️LOCAL DEV RESET DEPLOYMENT‼️</button>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import {
  useAccount,
  useBalance,
  useChainId,
  useChains,
  useDisconnect,
  useReadContract
} from '@wagmi/vue'
import { useStorage } from '@vueuse/core'
import { cgsTokenAbi } from '@/assets/contract-artifacts/wagmi-generated'
import { localhost } from '@/lib/wagmi/config'

const { address, connector } = useAccount()
const { disconnect } = useDisconnect()
const chainId = useChainId()
const chains = useChains()
const tokenContractAddress = useStorage(
  'VITE_CGS_TOKEN_CONTRACT_ADDRESS',
  import.meta.env.VITE_CGS_TOKEN_CONTRACT_ADDRESS
)
const currentChain = computed(() => {
  return chains.value.find((chain) => chain.id === chainId.value)
})
const { data: balance } = useBalance({ address })
const { data: userTokenBalance } = useReadContract({
  address: tokenContractAddress.value as `0x${string}`,
  abi: cgsTokenAbi,
  functionName: 'balanceOf' as const,
  args: [ address.value as `0x${string}` ],
  query: { enabled: !!address && !!tokenContractAddress.value }
})
const resetLocalDevDeployment = async () => {
  console.log('Resetting local dev deployment...', chainId.value, localhost.id)
  if (chainId.value === localhost.id) {
    useStorage(
      'VITE_CGS_TOKEN_CONTRACT_ADDRESS',
      import.meta.env.VITE_CGS_TOKEN_CONTRACT_ADDRESS
    ).value = ''
    useStorage(
      'VITE_CGS_PRESALE_CONTRACT_ADDRESS',
      import.meta.env.VITE_CGS_PRESALE_CONTRACT_ADDRESS
    ).value = ''
    useStorage(
      'VITE_CGS_VESTING_CONTRACT_ADDRESS',
      import.meta.env.VITE_CGS_VESTING_CONTRACT_ADDRESS
    ).value = ''
    useStorage(
      'VITE_USDC_CONTRACT_ADDRESS',
      import.meta.env.VITE_USDC_CONTRACT_ADDRESS
    ).value = ''
    useStorage(
      'VITE_USDT_CONTRACT_ADDRESS',
      import.meta.env.VITE_USDT_CONTRACT_ADDRESS
    ).value = ''
  }
}
</script>
