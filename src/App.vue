<template>
  <div>
    <Account v-if="isConnected" />
    <Connect v-else />
  </div>
  <hr />
  <div>
    <DeployToken />
    <DeployPresale v-if="tokenContractAddress" />
    <DeployVesting v-if="tokenContractAddress" />
  </div>
</template>

<script setup lang="ts">
import { useAccount } from '@wagmi/vue'
import { useStorage } from '@vueuse/core'

import Account from './components/Account.vue'
import Connect from './components/Connect.vue'
import DeployToken from './components/DeployToken.vue'
import DeployPresale from './components/DeployPresale.vue'
import DeployVesting from './components/DeployVesting.vue'

const { isConnected } = useAccount()
const tokenContractAddress = useStorage(
  'VITE_CGS_TOKEN_CONTRACT_ADDRESS',
  import.meta.env.VITE_CGS_TOKEN_CONTRACT_ADDRESS
)
</script>
