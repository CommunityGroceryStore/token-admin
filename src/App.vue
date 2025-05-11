<template>
  <section>
    <Account v-if="isConnected" />
    <Connect v-else />
  </section>
  <hr />
  <section v-if="isConnected">
    <DeployToken />
    <template v-if="tokenContractAddress">
      <DeployMockStablecoins
        v-if="chainId === localhost.id || chainId === sepolia.id"
      />
      <DeployPresale />
      <DeployVesting />
    </template>
    <template
      v-if="
        tokenContractAddress &&
          vestingContractAddress &&
          presaleContractAddress
      "
    >
      <ConnectPresaleAndVesting />
      <SendTokensToPresale />
      <AddPresalePaymentTokens />
    </template>
    <p
      v-if="
        tokenContractAddress &&
          presaleContractAddress &&
          vestingContractAddress &&
          usdcContractAddress && usdcRate &&
          usdtContractAddress && usdtRate &&
          isVestingContractAddressSetInPresaleContract &&
          isPresaleContractAVestingAdmin &&
          presaleContractTokenBalance
      "
    >
      🎉 Presale is ready to start!
    </p>
    <p v-if="hasDefaultAdminRoleOnTokenContract">
      ⚠️ You still have the Default Admin Role on the Token Contract.<br />
      This should be transferred to a Multisig.
    </p>
    <p v-if="hasDefaultAdminRoleOnPresaleContract">
      ⚠️ You still have the Default Admin Role on the Presale Contract.<br />
      This should be transferred to a Multisig.
    </p>
    <p v-if="hasDefaultAdminRoleOnVestingContract">
      ⚠️ You still have the Default Admin Role on the Vesting Contract.<br />
      This should be transferred to a Multisig.
    </p>
  </section>
</template>

<script setup lang="ts">
import { useAccount, useChainId, useReadContract } from '@wagmi/vue'
import { useStorage } from '@vueuse/core'
import { sepolia } from '@wagmi/vue/chains'
import { ethers } from 'ethers'

import { localhost } from '@/lib/wagmi/config'
import Account from '@/components/Account.vue'
import Connect from '@/components/Connect.vue'
import DeployToken from '@/components/DeployToken.vue'
import DeployPresale from '@/components/DeployPresale.vue'
import DeployVesting from '@/components/DeployVesting.vue'
import ConnectPresaleAndVesting from '@/components/ConnectPresaleAndVesting.vue'
import DeployMockStablecoins from '@/components/DeployMockStablecoins.vue'
import SendTokensToPresale from '@/components/SendTokensToPresale.vue'
import AddPresalePaymentTokens from '@/components/AddPresalePaymentTokens.vue'
import {
  cgsTokenAbi,
  cgsTokenPresaleAbi,
  cgsVestingAbi
} from '@/assets/contract-artifacts/wagmi-generated'

const { address, isConnected } = useAccount()
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
const usdcContractAddress = useStorage(
  'VITE_USDC_CONTRACT_ADDRESS',
  import.meta.env.VITE_USDC_CONTRACT_ADDRESS
)
const usdtContractAddress = useStorage(
  'VITE_USDT_CONTRACT_ADDRESS',
  import.meta.env.VITE_USDT_CONTRACT_ADDRESS
)
const { data: usdcRate } = useReadContract({
  address: presaleContractAddress.value as `0x${string}`,
  abi: cgsTokenPresaleAbi,
  functionName: 'paymentTokenRates' as const,
  args: [ usdcContractAddress.value as `0x${string}` ],
  query: { enabled: !!usdcContractAddress.value }
})
const { data: usdtRate } = useReadContract({
  address: presaleContractAddress.value as `0x${string}`,
  abi: cgsTokenPresaleAbi,
  functionName: 'paymentTokenRates' as const,
  args: [ usdtContractAddress.value as `0x${string}` ],
  query: { enabled: !!usdtContractAddress.value }
})
const {
  data: isVestingContractAddressSetInPresaleContract
} = useReadContract({
  address: presaleContractAddress.value as `0x${string}`,
  abi: cgsTokenPresaleAbi,
  functionName: 'vestingContractAddress' as const,
  query: { enabled: !!presaleContractAddress.value }
})
const {
  data: isPresaleContractAVestingAdmin
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
const {
  data: presaleContractTokenBalance
} = useReadContract({
  address: tokenContractAddress.value as `0x${string}`,
  abi: cgsTokenAbi,
  functionName: 'balanceOf' as const,
  args: [ presaleContractAddress.value as `0x${string}` ],
  query: {
    enabled: !!tokenContractAddress.value && !!presaleContractAddress.value
  }
})
const {
  data: hasDefaultAdminRoleOnTokenContract
} = useReadContract({
  address: tokenContractAddress.value as `0x${string}`,
  abi: cgsTokenAbi,
  functionName: 'hasRole' as const,
  args: [
    '0x0000000000000000000000000000000000000000000000000000000000000000',
    address.value as `0x${string}`
  ],
  query: { enabled: !!tokenContractAddress.value && !!address.value }
})
const {
  data: hasDefaultAdminRoleOnPresaleContract
} = useReadContract({
  address: presaleContractAddress.value as `0x${string}`,
  abi: cgsTokenPresaleAbi,
  functionName: 'hasRole' as const,
  args: [
    '0x0000000000000000000000000000000000000000000000000000000000000000',
    address.value as `0x${string}`
  ],
  query: { enabled: !!presaleContractAddress.value && !!address.value }
})
const {
  data: hasDefaultAdminRoleOnVestingContract
} = useReadContract({
  address: vestingContractAddress.value as `0x${string}`,
  abi: cgsVestingAbi,
  functionName: 'hasRole' as const,
  args: [
    '0x0000000000000000000000000000000000000000000000000000000000000000',
    address.value as `0x${string}`
  ],
  query: { enabled: !!vestingContractAddress.value && !!address.value }
})
</script>
