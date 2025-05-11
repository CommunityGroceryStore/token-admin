<template>
  <section>
    <Account v-if="isConnected" />
    <Connect v-else />
  </section>
  <hr />
  <section v-if="isConnected">
    <DeployToken />
    <DeployMockStablecoins
      v-if="chainId === localhost.id || chainId === sepolia.id"
    />
    <DeployPresale v-if="tokenContractAddress" />
    <DeployVesting v-if="tokenContractAddress" />
    <ConnectPresaleAndVesting
      v-if="
        tokenContractAddress &&
          vestingContractAddress &&
          presaleContractAddress
      "
    />
  </section>
</template>

<script setup lang="ts">
import { useAccount, useChainId } from '@wagmi/vue'
import { useStorage } from '@vueuse/core'
import { sepolia } from '@wagmi/vue/chains'
import { localhost } from '@/lib/wagmi/config'
import Account from '@/components/Account.vue'
import Connect from '@/components/Connect.vue'
import DeployToken from '@/components/DeployToken.vue'
import DeployPresale from '@/components/DeployPresale.vue'
import DeployVesting from '@/components/DeployVesting.vue'
import ConnectPresaleAndVesting from '@/components/ConnectPresaleAndVesting.vue'
import DeployMockStablecoins from '@/components/DeployMockStablecoins.vue'

const { isConnected } = useAccount()
const chainId = useChainId()
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
</script>
