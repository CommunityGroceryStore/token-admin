<template>
  <p v-if="status === 'pending'">
    ⚠️ Checking Default Admin Role on {{ contractName }} Contract...
  </p>
  <p v-if="error">
    ‼️ Error checking Default Admin Role on {{ contractName }} Contract:
    {{ error.message }}
  </p>
  <p v-if="hasDefaultAdminRole">
    ⚠️ You still have the Default Admin Role on the {{ contractName }} Contract. This should be transferred to a Multisig.
  </p>
</template>

<script setup lang="ts">
import { useReadContract } from '@wagmi/vue'
import { accessControlAbi } from '@/assets/contract-artifacts/wagmi-generated'

const {
  checkAddress,
  contractAddress,
  contractName  
} = defineProps<{
  checkAddress: `0x${string}`,
  contractAddress: `0x${string}`,
  contractName: string
}>()
const {
  data: hasDefaultAdminRole,
  status,
  error
} = useReadContract({
  address: contractAddress,
  abi: accessControlAbi,
  functionName: 'hasRole' as const,
  args: [
    '0x0000000000000000000000000000000000000000000000000000000000000000',
    checkAddress
  ],
  query: { enabled: !!checkAddress && !!contractAddress }
})
</script>
