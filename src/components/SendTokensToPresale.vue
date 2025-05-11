<template>
  <div>
    <div v-if="isConnected">
      <div
        v-if="presaleContractTokenBalance && presaleContractTokenBalance > 0"
      >
        <p>
          ✔️ Presale Contract has
          {{
            (
              presaleContractTokenBalance / 1_000_000_000_000_000_000n
            ).toLocaleString(undefined, { minimumFractionDigits: 2 })
          }} $CGS Tokens
        </p>
      </div>
      <div v-else>
        <p>🔘 Send $CGS to Presale Contract</p>
        <label for="tokensToSend">Amount $CGS send:</label>
        <input
          v-model="tokensToSend"
          name="tokensToSend"
          type="number"
          :disabled="deploying"
        />
        <button
          @click="sendTokensToPresaleContract()"
          :disabled="deploying"
        >
          {{
            deploying
              ? 'Sending $CGS Tokens to Presale Contract...'
              : 'Send $CGS Tokens to Presale Contract'
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
import { useAccount, useReadContract, useWriteContract } from '@wagmi/vue'
import { useStorage } from '@vueuse/core'
import { ethers } from 'ethers'
import { cgsTokenAbi } from '@/assets/contract-artifacts/wagmi-generated'

const { isConnected } = useAccount()
const { writeContractAsync } = useWriteContract()
const deploying = ref(false)
const tokensToSend = ref(100_000_000)
const presaleContractAddress = useStorage(
  'VITE_CGS_PRESALE_CONTRACT_ADDRESS',
  import.meta.env.VITE_CGS_PRESALE_CONTRACT_ADDRESS
)
const tokenContractAddress = useStorage(
  'VITE_CGS_TOKEN_CONTRACT_ADDRESS',
  import.meta.env.VITE_CGS_TOKEN_CONTRACT_ADDRESS
)

const {
  data: presaleContractTokenBalance,
  refetch: refetchPresaleContractTokenBalance
} = useReadContract({
  address: tokenContractAddress.value as `0x${string}`,
  abi: cgsTokenAbi,
  functionName: 'balanceOf' as const,
  args: [ presaleContractAddress.value as `0x${string}` ]
})
const sendTokensToPresaleContract = async () => {
  if (!isConnected.value) { return }
  if (!presaleContractAddress.value) {
    console.error('No presale contract address')
    return
  }
  if (!tokenContractAddress.value) {
    console.error('No token contract address')
    return
  }
  deploying.value = true
  try {
    await writeContractAsync({
      address: tokenContractAddress.value as `0x${string}`,
      abi: cgsTokenAbi,
      functionName: 'transfer' as const,
      args: [
        presaleContractAddress.value as `0x${string}`,
        ethers.parseUnits(tokensToSend.value.toString(), 18)
      ]
    })
  } catch (err) {
    console.error('Error sending tokens to presale contract', err)
  } finally {
    await refetchPresaleContractTokenBalance()
    deploying.value = false
  }
}
</script>
