<template>
  <div>
    <div v-if="isConnected">
      <div v-if="isVestingContractAddressSetInPresaleContract">
        <p>
          ✔️ Vesting Contract Address is set in Presale Contract
        </p>
      </div>
      <div v-else>
        🔘
        <button
          @click="setVestingContractAddressInPresaleContract()"
          :disabled="deploying"
        >
          {{
            deploying
              ? 'Setting Vesting Contract Address in Presale Contract...'
              : 'Set Vesting Contract Address in Presale Contract'
          }}
        </button>
      </div>

      <div v-if="isPresaleContractAVestingAdmin">
        <p>
          ✔️ Presale Contract is a Vesting Admin
        </p>
      </div>
      <div v-else>
        🔘
        <button
          @click="grantVestingAdminRoleToPresaleContract()"
          :disabled="deploying"
        >
          {{
            deploying
              ? 'Granting Vesting Admin Role to Presale Contract...'
              : 'Grant Vesting Admin Role to Presale Contract'
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

import {
  cgsTokenPresaleAbi,
  cgsVestingAbi
} from '@/assets/contract-artifacts/wagmi-generated'

const { isConnected } = useAccount()
const { writeContractAsync } = useWriteContract()
const deploying = ref(false)
const presaleContractAddress = useStorage(
  'VITE_CGS_PRESALE_CONTRACT_ADDRESS',
  import.meta.env.VITE_CGS_PRESALE_CONTRACT_ADDRESS
)
const vestingContractAddress = useStorage(
  'VITE_CGS_VESTING_CONTRACT_ADDRESS',
  import.meta.env.VITE_CGS_PRESALE_CONTRACT_ADDRESS
)

const {
  data: isVestingContractAddressSetInPresaleContract,
  refetch: refetchIsVestingContractAddressSetInPresaleContract
} = useReadContract({
  address: presaleContractAddress.value as `0x${string}`,
  abi: cgsTokenPresaleAbi,
  functionName: 'vestingContractAddress' as const,
  query: { enabled: !!presaleContractAddress.value }
})
const setVestingContractAddressInPresaleContract = async () => {
  if (!isConnected.value) { return }
  if (!presaleContractAddress.value) {
    console.error('No presale contract address')
    return
  }
  if (!vestingContractAddress.value) {
    console.error('No vesting contract address')
    return
  }
  deploying.value = true
  try {
    await writeContractAsync({
      address: presaleContractAddress.value as `0x${string}`,
      abi: cgsTokenPresaleAbi,
      functionName: 'setVestingContractAddress' as const,
      args: [ vestingContractAddress.value as `0x${string}` ]
    })
  } catch (err) {
    console.error(
      'Error setting vesting contract address in presale contract',
      err
    )
  } finally {
    await refetchIsVestingContractAddressSetInPresaleContract()
    deploying.value = false
  }
}

const {
  data: isPresaleContractAVestingAdmin,
  refetch: refetchIsPresaleContractAVestingAdmin
} = useReadContract({
  address: vestingContractAddress.value as `0x${string}`,
  abi: cgsVestingAbi,
  functionName: 'hasRole' as const,
  args: [
    ethers.id('VESTING_ADMIN_ROLE') as `0x${string}`,
    presaleContractAddress.value as `0x${string}`
  ],
  query: { enabled: !!presaleContractAddress.value }
})
const grantVestingAdminRoleToPresaleContract = async () => {
  if (!isConnected.value) { return }
  if (!presaleContractAddress.value) {
    console.error('No presale contract address')
    return
  }
  if (!vestingContractAddress.value) {
    console.error('No vesting contract address')
    return
  }
  deploying.value = true
  try {
    await writeContractAsync({
      address: vestingContractAddress.value as `0x${string}`,
      abi: cgsVestingAbi,
      functionName: 'grantRole' as const,
      args: [
        ethers.id('VESTING_ADMIN_ROLE') as `0x${string}`,
        presaleContractAddress.value as `0x${string}`
      ]
    })
  } catch (err) {
    console.error(
      'Error granting vesting admin role to presale contract',
      err
    )
  } finally {
    await refetchIsPresaleContractAVestingAdmin()
    deploying.value = false
  }
}
</script>
