<template>
  <h1>Deploy</h1>
  <section v-if="isConnected">
    <label for="multisigAddress">
      Multisig Address
    </label>
    <input
      name="multisigAddress"
      v-model="multisigAddress"
      :style="
        !!tokenContractAddress && isValidMultisigAddress
          ? 'border: 0;'
          : ''
      "
      :disabled="!!tokenContractAddress && isValidMultisigAddress"
      placeholder="0x..."
    />
  </section>
  <section v-if="isConnected && isValidMultisigAddress">
    <DeployToken :multisigAddress="multisigAddress" />
    <template v-if="tokenContractAddress">
      <DeployMockStablecoins
        v-if="chainId === localhost.id || chainId === sepolia.id"
      />
      <DeployVesting :multisigAddress="multisigAddress" />
      <DeployPresale
        v-if="vestingContractAddress"
        :multisigAddress="multisigAddress"
      />
    </template>
    <template
      v-if="
        tokenContractAddress &&
          vestingContractAddress &&
          presaleContractAddress
      "
    >
      <ConnectPresaleAndVesting />
      <AddPresalePaymentTokens />
      <SendTokensToPresale />      
    </template>

    <CheckDefaultAdminRole
      v-if="address && tokenContractAddress"
      :checkAddress="address"
      :contractAddress="tokenContractAddress"
      contractName="Token"
    />

    <CheckDefaultAdminRole
      v-if="address && vestingContractAddress"
      :checkAddress="address"
      :contractAddress="vestingContractAddress"
      contractName="Vesting"
    />

    <CheckDefaultAdminRole
      v-if="address && presaleContractAddress"
      :checkAddress="address"
      :contractAddress="presaleContractAddress"
      contractName="Presale"
    />

    <CopyDeploymentAddresses />

    <p
      v-if="
        tokenContractAddress &&
          presaleContractAddress &&
          vestingContractAddress &&
          usdcContractAddress && usdcRate &&
          usdtContractAddress && usdtRate &&
          isVestingContractAddressSetInPresaleContract &&
          !!isPresaleContractAVestingAdmin &&
          presaleContractTokenBalance
      "
    >
      🎉 Presale is ready to start!
    </p>
  </section>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useAccount, useChainId, useReadContract } from '@wagmi/vue'
import { useStorage } from '@vueuse/core'
import { sepolia } from '@wagmi/vue/chains'
import { ethers } from 'ethers'

import { localhost } from '@/lib/wagmi/config'

import DeployToken from '@/components/DeployToken.vue'
import DeployPresale from '@/components/DeployPresale.vue'
import DeployVesting from '@/components/DeployVesting.vue'
import ConnectPresaleAndVesting from '@/components/ConnectPresaleAndVesting.vue'
import DeployMockStablecoins from '@/components/DeployMockStablecoins.vue'
import SendTokensToPresale from '@/components/SendTokensToPresale.vue'
import AddPresalePaymentTokens from '@/components/AddPresalePaymentTokens.vue'
import CheckDefaultAdminRole from '@/components/CheckDefaultAdminRole.vue'
import CopyDeploymentAddresses from '@/components/CopyDeploymentAddresses.vue'
import {
  cgsTokenAbi,
  cgsTokenPresaleAbi,
  cgsVestingAbi
} from '@/assets/contract-artifacts/wagmi-generated'

const { address, isConnected } = useAccount()
const chainId = useChainId()
const multisigAddress = useStorage<`0x${string}`>(
  'VITE_CGS_MULTISIG_ADDRESS',
  import.meta.env.VITE_CGS_MULTISIG_ADDRESS
)
const tokenContractAddress = useStorage<`0x${string}`>(
  'VITE_CGS_TOKEN_CONTRACT_ADDRESS',
  import.meta.env.VITE_CGS_TOKEN_CONTRACT_ADDRESS as `0x${string}`
)
const presaleContractAddress = useStorage<`0x${string}`>(
  'VITE_CGS_PRESALE_CONTRACT_ADDRESS',
  import.meta.env.VITE_CGS_PRESALE_CONTRACT_ADDRESS as `0x${string}`
)
const vestingContractAddress = useStorage<`0x${string}`>(
  'VITE_CGS_VESTING_CONTRACT_ADDRESS',
  import.meta.env.VITE_CGS_VESTING_CONTRACT_ADDRESS as `0x${string}`
)
const usdcContractAddress = useStorage<`0x${string}`>(
  'VITE_USDC_CONTRACT_ADDRESS',
  import.meta.env.VITE_USDC_CONTRACT_ADDRESS as `0x${string}`
)
const usdtContractAddress = useStorage<`0x${string}`>(
  'VITE_USDT_CONTRACT_ADDRESS',
  import.meta.env.VITE_USDT_CONTRACT_ADDRESS as `0x${string}`
)
const isValidMultisigAddress = computed(() => {
  if (!multisigAddress.value) { return false }
  return ethers.isAddress(multisigAddress.value)
})
const { data: usdcRate } = useReadContract({
  address: presaleContractAddress.value,
  abi: cgsTokenPresaleAbi,
  functionName: 'paymentTokenRates' as const,
  args: [ usdcContractAddress.value ],
  query: { enabled: computed(() => !!usdcContractAddress.value) }
})
const { data: usdtRate } = useReadContract({
  address: presaleContractAddress.value,
  abi: cgsTokenPresaleAbi,
  functionName: 'paymentTokenRates' as const,
  args: [ usdtContractAddress.value ],
  query: { enabled: computed(() => !!usdtContractAddress.value) }
})
const {
  data: isVestingContractAddressSetInPresaleContract
} = useReadContract({
  address: presaleContractAddress.value,
  abi: cgsTokenPresaleAbi,
  functionName: 'vestingContractAddress' as const,
  query: { enabled: computed(() => !!presaleContractAddress.value) }
})
const {
  data: isPresaleContractAVestingAdmin
} = useReadContract({
  address: vestingContractAddress.value,
  abi: cgsVestingAbi,
  functionName: 'hasRole' as const,
  args: [
    ethers.id('VESTING_ADMIN_ROLE') as `0x${string}`,
    presaleContractAddress.value
  ],
  query: { enabled: computed(() => !!presaleContractAddress.value) }
})
const {
  data: presaleContractTokenBalance
} = useReadContract({
  address: tokenContractAddress.value,
  abi: cgsTokenAbi,
  functionName: 'balanceOf' as const,
  args: [ presaleContractAddress.value ],
  query: {
    enabled: computed(() => !!tokenContractAddress.value && !!presaleContractAddress.value)
  }
})
</script>
