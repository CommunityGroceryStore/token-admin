<template>
  <div>
    <div v-if="isConnected">
      <div v-if="usdcRate">
        <p>
          ✔️ $USDC added to Presale Contract as Payment Token
          with rate {{ ethers.formatUnits(usdcRate, 6) }} $USDC
        </p>
      </div>
      <div v-else>
        <p>🔘 Add $USDC to Presale Contract as Payment Token</p>        
        <label for="desiredUsdcRate">$USDC per $CGS:</label>
        <input
          v-model="desiredUsdcRate"
          name="desiredUsdcRate"
          type="number"
          :disabled="deploying"
        />
        <button @click="addPresalePaymentToken('USDC')" :disabled="deploying">
          {{
            deploying
              ? 'Adding $USDC to Presale Contract as Payment Token...'
              : 'Add $USDC to Presale Contract as Payment Token'
          }}
        </button>
      </div>
      <div v-if="usdtRate">
        <p>
          ✔️ $USDT added to Presale Contract as Payment Token
          with rate {{ ethers.formatUnits(usdtRate, 6) }} $USDT
        </p>
      </div>
      <div v-else>
        <p>🔘 Add $USDT to Presale Contract as Payment Token</p>        
        <label for="desiredUsdtRate">$USDT per $CGS:</label>
        <input
          v-model="desiredUsdtRate"
          name="desiredUsdtRate"
          type="number"
          :disabled="deploying"
        />
        <button @click="addPresalePaymentToken('USDT')" :disabled="deploying">
          {{
            deploying
              ? 'Adding $USDT to Presale Contract as Payment Token...'
              : 'Add $USDT to Presale Contract as Payment Token'
          }}
        </button>
      </div>
    </div>
    <div v-else>
      connect to continue
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import {
  useAccount,
  useReadContract,
  useWriteContract
} from '@wagmi/vue'
import { useStorage } from '@vueuse/core'
import { ethers } from 'ethers'

import { cgsTokenPresaleAbi } from '@/assets/contract-artifacts/wagmi-generated'

const { isConnected } = useAccount()
const { writeContractAsync } = useWriteContract()
const deploying = ref(false)
const desiredUsdcRate = ref(0.04)
const desiredUsdtRate = ref(0.04)
const usdcContractAddress = useStorage(
  'VITE_USDC_CONTRACT_ADDRESS',
  import.meta.env.VITE_USDC_CONTRACT_ADDRESS
)
const usdtContractAddress = useStorage(
  'VITE_USDT_CONTRACT_ADDRESS',
  import.meta.env.VITE_USDT_CONTRACT_ADDRESS
)
const presaleContractAddress = useStorage(
  'VITE_CGS_PRESALE_CONTRACT_ADDRESS',
  import.meta.env.VITE_CGS_PRESALE_CONTRACT_ADDRESS
)

const { data: usdcRate, refetch: refetchUsdcRate } = useReadContract({
  address: presaleContractAddress.value as `0x${string}`,
  abi: cgsTokenPresaleAbi,
  functionName: 'paymentTokenRates' as const,
  args: [ usdcContractAddress.value as `0x${string}` ],
  query: { enabled: !!usdcContractAddress.value }
})
const { data: usdtRate, refetch: refetchUsdtRate } = useReadContract({
  address: presaleContractAddress.value as `0x${string}`,
  abi: cgsTokenPresaleAbi,
  functionName: 'paymentTokenRates' as const,
  args: [ usdtContractAddress.value as `0x${string}` ],
  query: { enabled: !!usdtContractAddress.value }
})
const addPresalePaymentToken = async (ticker: 'USDC' | 'USDT') => {
  if (!isConnected.value) { return }
  if (!presaleContractAddress.value) {
    console.error('No presale contract address')
    return
  }
  if (!usdcContractAddress.value && ticker === 'USDC') {
    console.error('No USDC contract address')
    return
  }
  if (!usdtContractAddress.value && ticker === 'USDT') {
    console.error('No USDT contract address')
    return
  }

  deploying.value = true
  try {
    const address: `0x${string}` = ticker === 'USDC'
      ? usdcContractAddress.value
      : usdtContractAddress.value
    const rate: bigint = ticker === 'USDC'
      ? ethers.parseUnits(desiredUsdcRate.value.toString(), 6)
      : ethers.parseUnits(desiredUsdtRate.value.toString(), 6)
    await writeContractAsync({
      address: presaleContractAddress.value as `0x${string}`,
      abi: cgsTokenPresaleAbi,
      functionName: 'addPaymentToken' as const,
      args: [ address, rate ]
    })
  } catch (err) {
    console.error('Deployment failed: ' + (err as Error).message)
  } finally {
    if (ticker === 'USDC') { await refetchUsdcRate() }
    if (ticker === 'USDT') { await refetchUsdtRate() }
    deploying.value = false
  }
}
</script>
