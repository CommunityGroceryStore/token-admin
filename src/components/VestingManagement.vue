<template>
  <h1>Vesting</h1>

  <CheckDefaultAdminRole
    v-if="address && vestingContractAddress"
    :checkAddress="address"
    :contractAddress="vestingContractAddress"
    contractName="Vesting"
  />

  <table>
    <tbody>
      <tr>
        <td>Vesting Contract Address</td>
        <td>{{ vestingContractAddress }}</td>
      </tr>
      <tr>
        <td>Vesting Contract $CGS Balance</td>
        <td v-if="vestingContractBalance || vestingContractBalance === 0n">
          {{ ethers.formatUnits(vestingContractBalance, 18) }} $CGS
        </td>
      </tr>
    </tbody>
  </table>

  <section>
    <label for="beneficiaryAddress">Check Beneficiary Address</label>
    <input
      id="beneficiaryAddress"
      type="text"
      v-model="beneficiaryAddress"
      placeholder="0x..."
      :disabled="
        isCheckingBeneficiaryAddress ||
        isCheckingBeneficiaryVestingSchedule
      "
    />
    <button @click="checkBeneficiaryAddress()">
      Check Beneficiary Address
    </button>
    <table>
      <tbody>
        <template
          v-if="
            beneficiaryVestedAndClaimableTokensStatus === 'success' &&
            beneficiaryVestedAndClaimableTokens
          "
        >
          <tr>
            <td>Vested Tokens</td>
            <td>
              {{ ethers.formatUnits(beneficiaryVestedAndClaimableTokens[0], 18) }} $CGS
            </td>
          </tr>
          <tr>
            <td>Claimable Tokens</td>
            <td>
              {{ ethers.formatUnits(beneficiaryVestedAndClaimableTokens[1], 18) }} $CGS
            </td>
          </tr>
        </template>
        
        <template
          v-if="
            beneficiaryVestingScheduleStatus === 'success' &&
            beneficiaryVestingSchedule &&
            beneficiaryVestingSchedule.length > 0 &&
            beneficiaryVestingSchedule[5]
          "
        >
          <tr>
            <td>Total Allocated Tokens</td>
            <td>
              {{ ethers.formatUnits(beneficiaryVestingSchedule[0], 18) }} $CGS
            </td>
          </tr>
          <tr>
            <td>Claimed Tokens</td>
            <td>
              {{ ethers.formatUnits(beneficiaryVestingSchedule[1], 18) }} $CGS
            </td>
          </tr>
          <tr>
            <td>Start</td>
            <td>
              {{ new Date(Number(beneficiaryVestingSchedule[2]) * 1000).toUTCString() }}
            </td>
          </tr>
          <tr>
            <td>Cliff</td>
            <td>
              {{ new Date(Number(beneficiaryVestingSchedule[2] + beneficiaryVestingSchedule[4]) * 1000).toUTCString() }}
            </td>
          </tr>
          <tr>
            <td>Fully Vested</td>
            <td>
              {{ new Date(Number(beneficiaryVestingSchedule[2] + beneficiaryVestingSchedule[3]) * 1000).toUTCString() }}
            </td>
          </tr>
          <tr>
            <td>Vest Duration</td>
            <td>
              {{ beneficiaryVestingSchedule[3] }}
            </td>
          </tr>
        </template>
      </tbody>
    </table>
  </section>

  <section>
    <label for="newBeneficiaryAddress">Add New Vesting Schedule</label>
    <input
      id="newBeneficiaryAddress"
      type="text"
      v-model="newBeneficiaryAddress"
      placeholder="0x..."
      :disabled="isAddingNewVestingSchedule"
    />

    <label for="newVestingScheduleTokenAmount">$CGS Amount</label>
    <input
      id="newVestingScheduleTokenAmount"
      type="number"
      v-model="newVestingScheduleTokenAmount"
      :disabled="isAddingNewVestingSchedule"
    />

    <label for="newVestingScheduleStart">
      Vesting Start
    </label>
    <input
      id="newVestingScheduleStart"
      type="number"
      v-model="newVestingScheduleStart"
      :disabled="isAddingNewVestingSchedule"
    />

    <label for="newVestingScheduleCliff">
      Vesting Cliff
    </label>
    <input
      id="newVestingScheduleCliff"
      type="number"
      v-model="newVestingScheduleCliff"
      :disabled="isAddingNewVestingSchedule"
    />

    <label for="newVestingScheduleDuration">
      Vesting Duration
    </label>
    <input
      id="newVestingScheduleDuration"
      type="number"
      v-model="newVestingScheduleDuration"
      :disabled="isAddingNewVestingSchedule"
    />

    <button @click="addNewVestingSchedule()">
      Add New Vesting Schedule
    </button>
  </section>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useAccount, useReadContract, useWriteContract } from '@wagmi/vue'
import { useStorage } from '@vueuse/core'
import { ethers } from 'ethers'

import {
  cgsTokenAbi,
  cgsVestingAbi
} from '@/assets/contract-artifacts/wagmi-generated'
import CheckDefaultAdminRole from '@/components/CheckDefaultAdminRole.vue'

const { address } = useAccount()
const { writeContractAsync } = useWriteContract()
const vestingContractAddress = useStorage<`0x${string}`>(
  'VITE_CGS_VESTING_CONTRACT_ADDRESS',
  import.meta.env.VITE_CGS_VESTING_CONTRACT_ADDRESS as `0x${string}`
)
const tokenContractAddress = useStorage<`0x${string}`>(
  'VITE_CGS_TOKEN_CONTRACT_ADDRESS',
  import.meta.env.VITE_CGS_TOKEN_CONTRACT_ADDRESS as `0x${string}`
)

const {
  data: vestingContractBalance
} = useReadContract({
  address: tokenContractAddress.value,
  abi: cgsTokenAbi,
  functionName: 'balanceOf' as const,
  args: [ vestingContractAddress.value ],
  query: {
    enabled: computed(() => !!tokenContractAddress.value)
  }
})

const beneficiaryAddress = ref('')
const checkBeneficiaryAddress = async () => {
  if (!beneficiaryAddress.value) {
    return
  }
  const isValidAddress = ethers.isAddress(beneficiaryAddress.value)
  if (!isValidAddress) {
    beneficiaryAddress.value = ''
    return
  }
  await refetchBeneficiaryVestedAndClaimableTokens()
  await refetchBeneficiaryVestingSchedule()
}
const {
  data: beneficiaryVestedAndClaimableTokens,
  status: beneficiaryVestedAndClaimableTokensStatus,
  isLoading: isCheckingBeneficiaryAddress,
  refetch: refetchBeneficiaryVestedAndClaimableTokens
} = useReadContract({
  address: vestingContractAddress.value,
  abi: cgsVestingAbi,
  functionName: 'getVestedAndClaimableTokens' as const,
  args: [
    computed(() => beneficiaryAddress.value as `0x${string}`)
  ],
  query: { enabled: false }
})
const {
  data: beneficiaryVestingSchedule,
  status: beneficiaryVestingScheduleStatus,
  isLoading: isCheckingBeneficiaryVestingSchedule,
  refetch: refetchBeneficiaryVestingSchedule
} = useReadContract({
  address: vestingContractAddress.value,
  abi: cgsVestingAbi,
  functionName: 'vestingSchedules' as const,
  args: [
    computed(() => beneficiaryAddress.value as `0x${string}`)
  ],
  query: { enabled: false }
})

const isAddingNewVestingSchedule = ref(false)
const newBeneficiaryAddress = ref('')
const newVestingScheduleTokenAmount = ref(0)
const newVestingScheduleStart = ref(Math.floor(Date.now() / 1000))
const newVestingScheduleDuration = ref(3600)
const newVestingScheduleCliff = ref(120)
const addNewVestingSchedule = async () => {
  if (!newBeneficiaryAddress.value) {
    return
  }
  const isValidAddress = ethers.isAddress(newBeneficiaryAddress.value)
  if (!isValidAddress) {
    newBeneficiaryAddress.value = ''
    return
  }
  isAddingNewVestingSchedule.value = true
  try {
    await writeContractAsync({
      address: tokenContractAddress.value,
      abi: cgsTokenAbi,
      functionName: 'approve' as const,
      args: [
        vestingContractAddress.value as `0x${string}`,
        ethers.parseUnits(newVestingScheduleTokenAmount.value.toString(), 18)
      ]
    })

    await writeContractAsync({
      address: vestingContractAddress.value,
      abi: cgsVestingAbi,
      functionName: 'addVestingSchedule' as const,
      args: [
        newBeneficiaryAddress.value as `0x${string}`,
        ethers.parseUnits(newVestingScheduleTokenAmount.value.toString(), 18),
        BigInt(newVestingScheduleStart.value),
        BigInt(newVestingScheduleDuration.value),
        BigInt(newVestingScheduleCliff.value)
      ]
    })
  } catch (error) {
    console.error('Error adding new vesting schedule:', error)
  } finally {
    isAddingNewVestingSchedule.value = false
  }
}
</script>
