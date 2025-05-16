<template>
  <h1>Presale</h1>

  <CheckDefaultAdminRole
    v-if="address && presaleContractAddress"
    :checkAddress="address"
    :contractAddress="presaleContractAddress"
    contractName="Presale"
  />

  <table>
    <tbody>
      <tr>
        <td>Presale Contract Address</td>
        <td>{{ presaleContractAddress }}</td>
      </tr>
      <tr>
        <td>Presale Contract $CGS Balance</td>
        <td v-if="presaleContractBalance || presaleContractBalance === 0n">
          {{ ethers.formatUnits(presaleContractBalance, 18) }} $CGS
        </td>
      </tr>
      <tr>
        <td>Presale Status</td>
        <td :style="isPresalePaused ? 'color: yellow;' : 'color: green;'">
          {{ isPresalePaused ? 'Paused' : 'Unpaused' }}
        </td>
      </tr>
      <tr>
        <td>Presale Treasury Address</td>
        <td>{{ presaleTreasuryAddress }}</td>
      </tr>
      <tr>
        <td>Presale Tokens Sold</td>
        <td>{{ presaleTokensSold }} $CGS</td>
      </tr>
      <tr>
        <td>Presale Vesting Duration (Seconds)</td>
        <td v-if="vestingSchedule">{{ vestingSchedule[0] }}</td>
      </tr>
      <tr>
        <td>Presale Vesting Cliff (Seconds)</td>
        <td v-if="vestingSchedule">{{ vestingSchedule[1] }}</td>
      </tr>
    </tbody>
  </table>

  <table>
    <thead>
      <tr>
        <th>Payment Token</th>
        <th>Token Address</th>
        <th>Rate</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>USDC</td>
        <td>{{ usdcContractAddress }}</td>
        <td v-if="usdcRate">{{ ethers.formatUnits(usdcRate, 6) }}</td>
      </tr>
      <tr>
        <td>USDT</td>
        <td>{{ usdtContractAddress }}</td>
        <td v-if="usdtRate">{{ ethers.formatUnits(usdtRate, 6) }}</td>
      </tr>
    </tbody>
  </table>

  <button
    v-if="isPresalePausedStatus === 'success'"
    @click="togglePresalePause(!isPresalePaused)"
    :disabled="isTogglingPresalePause"
  >
    {{ isPresalePaused ? 'Unpause Presale' : 'Pause Presale' }}
  </button>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useAccount, useReadContract, useWriteContract } from '@wagmi/vue'
import { useStorage } from '@vueuse/core'
import { ethers } from 'ethers'

import {
  cgsTokenAbi,
  cgsTokenPresaleAbi
} from '@/assets/contract-artifacts/wagmi-generated'
import CheckDefaultAdminRole from '@/components/CheckDefaultAdminRole.vue'

const { address } = useAccount()
const { writeContractAsync } = useWriteContract()
const presaleContractAddress = useStorage<`0x${string}`>(
  'VITE_CGS_PRESALE_CONTRACT_ADDRESS',
  import.meta.env.VITE_CGS_PRESALE_CONTRACT_ADDRESS as `0x${string}`
)
const usdcContractAddress = useStorage(
  'VITE_USDC_CONTRACT_ADDRESS',
  import.meta.env.VITE_USDC_CONTRACT_ADDRESS
)
const usdtContractAddress = useStorage(
  'VITE_USDT_CONTRACT_ADDRESS',
  import.meta.env.VITE_USDT_CONTRACT_ADDRESS
)
const tokenContractAddress = useStorage<`0x${string}`>(
  'VITE_CGS_TOKEN_CONTRACT_ADDRESS',
  import.meta.env.VITE_CGS_TOKEN_CONTRACT_ADDRESS as `0x${string}`
)

const {
  data: presaleContractBalance
} = useReadContract({
  address: tokenContractAddress.value,
  abi: cgsTokenAbi,
  functionName: 'balanceOf' as const,
  args: [ presaleContractAddress.value ],
  query: {
    enabled: computed(() => !!tokenContractAddress.value)
  }
})

const {
  data: isPresalePaused,
  status: isPresalePausedStatus,
  refetch: refetchIsPresalePaused
} = useReadContract({
  address: presaleContractAddress.value,
  abi: cgsTokenPresaleAbi,
  functionName: 'isPresalePaused' as const,
  query: {
    enabled: computed(() => !!presaleContractAddress.value)
  }
})

const {
  data: presaleTreasuryAddress
} = useReadContract({
  address: presaleContractAddress.value,
  abi: cgsTokenPresaleAbi,
  functionName: 'treasuryAddress' as const,
  query: {
    enabled: computed(() => !!presaleContractAddress.value)
  }
})

const {
  data: presaleTokensSold
} = useReadContract({
  address: presaleContractAddress.value,
  abi: cgsTokenPresaleAbi,
  functionName: 'presaleTokensSold' as const,
  query: {
    enabled: computed(() => !!presaleContractAddress.value)
  }
})

const {
  data: usdcRate
} = useReadContract({
  address: presaleContractAddress.value,
  abi: cgsTokenPresaleAbi,
  functionName: 'paymentTokenRates' as const,
  args: [ usdcContractAddress.value ],
  query: {
    enabled: computed(() => !!presaleContractAddress.value)
  }
})

const {
  data: usdtRate
} = useReadContract({
  address: presaleContractAddress.value,
  abi: cgsTokenPresaleAbi,
  functionName: 'paymentTokenRates' as const,
  args: [ usdtContractAddress.value ],
  query: {
    enabled: computed(() => !!presaleContractAddress.value)
  }
})

const {
  data: vestingSchedule
} = useReadContract({
  address: presaleContractAddress.value,
  abi: cgsTokenPresaleAbi,
  functionName: 'vestingSchedule' as const,
  query: {
    enabled: computed(() => !!presaleContractAddress.value)
  }
})

const isTogglingPresalePause = ref(false)
const togglePresalePause = async (paused: boolean) => {
  if (!presaleContractAddress.value) {
    console.error('No presale contract address')
    return
  }

  isTogglingPresalePause.value = true
  console.log('Toggling presale pause to', paused)
  try {
    await writeContractAsync({
      address: presaleContractAddress.value as `0x${string}`,
      abi: cgsTokenPresaleAbi,
      functionName: paused ? 'pausePresale' as const : 'unpausePresale' as const
    })
  } catch (err) {
    console.error(
      `Error toggling pause on presale contract: paused = ${paused}`,
      err
    )
  } finally {
    await refetchIsPresalePaused()
    isTogglingPresalePause.value = false
  }
}
</script>
