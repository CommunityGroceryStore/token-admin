<template>
  <p v-if="isEnvironmentConfigMissingVariables">
    ⚠️ Deployed Contract Addresses environment variables are not set!<br />
    Copy & paste the following to the dev so we don't have to find them again:
  </p>
  <code>
    VITE_CGS_TOKEN_CONTRACT_ADDRESS={{ tokenContractAddress }}
    VITE_CGS_PRESALE_CONTRACT_ADDRESS={{ presaleContractAddress }}
    VITE_CGS_VESTING_CONTRACT_ADDRESS={{ vestingContractAddress }}
    VITE_USDC_CONTRACT_ADDRESS={{ usdcContractAddress }}
    VITE_USDT_CONTRACT_ADDRESS={{ usdtContractAddress }}
    VITE_CGS_MULTISIG_ADDRESS={{ multisigAddress }}
  </code>
</template>

<script setup lang="ts">
import { useStorage } from '@vueuse/core'

const isEnvironmentConfigMissingVariables =
  !import.meta.env.VITE_CGS_TOKEN_CONTRACT_ADDRESS ||
  !import.meta.env.VITE_CGS_PRESALE_CONTRACT_ADDRESS ||
  !import.meta.env.VITE_CGS_VESTING_CONTRACT_ADDRESS ||
  !import.meta.env.VITE_USDC_CONTRACT_ADDRESS ||
  !import.meta.env.VITE_USDT_CONTRACT_ADDRESS ||
  !import.meta.env.VITE_CGS_MULTISIG_ADDRESS

const tokenContractAddress = useStorage(
  'VITE_CGS_TOKEN_CONTRACT_ADDRESS',
  import.meta.env.VITE_CGS_TOKEN_CONTRACT_ADDRESS
)
const presaleContractAddress = useStorage(
  'VITE_CGS_PRESALE_CONTRACT_ADDRESS',
  import.meta.env.VITE_CGS_PRESALE_CONTRACT_ADDRESS
)
const vestingContractAddress = useStorage(
  'VITE_CGS_VESTING_CONTRACT_ADDRESS',
  import.meta.env.VITE_CGS_VESTING_CONTRACT_ADDRESS
)
const usdcContractAddress = useStorage(
  'VITE_USDC_CONTRACT_ADDRESS',
  import.meta.env.VITE_USDC_CONTRACT_ADDRESS
)
const usdtContractAddress = useStorage(
  'VITE_USDT_CONTRACT_ADDRESS',
  import.meta.env.VITE_USDT_CONTRACT_ADDRESS
)
const multisigAddress = useStorage(
  'VITE_CGS_MULTISIG_ADDRESS',
  import.meta.env.VITE_CGS_MULTISIG_ADDRESS
)
</script>
