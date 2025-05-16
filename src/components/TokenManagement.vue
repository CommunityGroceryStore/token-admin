<template>
  <h1>Token</h1>

  <CheckDefaultAdminRole
    v-if="address && tokenContractAddress"
    :checkAddress="address"
    :contractAddress="tokenContractAddress"
    contractName="Token"
  />

  <table>
    <tbody>
      <tr>
        <td>$CGS Contract Address</td>
        <td>{{ tokenContractAddress }}</td>
      </tr>
      <tr>
        <td>Contract $CGS Balance (Taxes)</td>
        <td v-if="tokenContractBalance || tokenContractBalance === 0n">
          {{ ethers.formatUnits(tokenContractBalance, 18) }} $CGS
        </td>
      </tr>
      <tr>
        <td>Tax Status</td>
        <td>
          <span :style="isTaxPaused ? 'color: yellow;' : 'color: green;'">
            {{ isTaxPaused ? 'Paused' : 'Unpaused' }}
          </span>,
          <span
            :style="isTaxPermanentlyDisabled ? 'color: red;' : 'color: green;'"
          >
            {{ isTaxPermanentlyDisabled ? 'PERMANENTLY DISABLED' : 'Enabled' }}
          </span>
        </td>
      </tr>
      <tr>
        <td>Tax Buy Rate</td>
        <td v-if="taxBuyRateStatus === 'success' && taxBuyRate">
          {{ ethers.formatUnits(taxBuyRate, 3) }} %
        </td>
      </tr>
      <tr>
        <td>Tax Sell Rate</td>
        <td v-if="taxSellRateStatus === 'success' && taxSellRate">
          {{ ethers.formatUnits(taxSellRate, 3) }} %
        </td>
      </tr>
    </tbody>
  </table>

  <section>
    <button
      v-if="isTaxPausedStatus === 'success'"
      @click="toggleTaxPause(!isTaxPaused)"
      :disabled="isTogglingTaxPause"
    >
      {{ isTaxPaused ? 'Unpause Tax' : 'Pause Tax' }}
    </button>
  </section>

  <section>
    <label for="liquidityProvider">Liquidity Provider Address</label>
    <input
      id="liquidityProvider"
      type="text"
      v-model="liquidityProviderAddress"
      placeholder="0x..."
    />
    <button
      @click="addRemoveLiquidityProvider('add')"
      :disabled="isAddingRemovingLiquidityProvider"
    >
      Add Liquidity Provider Address
    </button>
    <button
      @click="addRemoveLiquidityProvider('remove')"
      :disabled="isAddingRemovingLiquidityProvider"
    >
      Remove Liquidity Provider Address
    </button>
  </section>

  <section>
    <label for="newTaxExemptAddress">Tax Exempt Address</label>
    <input
      id="newTaxExemptAddress"
      type="text"
      v-model="taxExemptAddress"
      placeholder="0x..."
    />
    <button
      @click="addRemoveTaxExemptAddress('add')"
      :disabled="isAddingRemovingNewTaxExemptAddress"
    >
      Add Tax Exempt Address
    </button>
    <button
      @click="addRemoveTaxExemptAddress('remove')"
      :disabled="isAddingRemovingNewTaxExemptAddress"
    >
      Remove Tax Exempt Address
    </button>
  </section>

  <section>
    <label for="newTaxRate">New Tax Rate</label>
    <input
      id="newTaxRate"
      type="number"
      v-model.number="newTaxRate"
      placeholder="0.000"
      min="0"
    />
    <button
      @click="updateTaxRate('buy')"
      :disabled="isUpdatingTaxRates"
    >
      Set Buy Tax Rate
    </button>
    <button
      @click="updateTaxRate('sell')"
      :disabled="isUpdatingTaxRates"
    >
      Set Sell Tax Rate
    </button>
  </section>

  <section>
    <button
      v-if="isTaxPermanentlyDisabledStatus === 'success'"
      @click="permanentlyDisableTax()"
      :disabled="isPermanentlyDisablingTax || isTaxPermanentlyDisabled"
    >
      Permanently Disable Tax
    </button>
  </section>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useAccount, useReadContract, useWriteContract } from '@wagmi/vue'
import { useStorage } from '@vueuse/core'
import { ethers } from 'ethers'

import { cgsTokenAbi } from '@/assets/contract-artifacts/wagmi-generated'
import CheckDefaultAdminRole from '@/components/CheckDefaultAdminRole.vue'

const { address } = useAccount()
const { writeContractAsync } = useWriteContract()
const tokenContractAddress = useStorage<`0x${string}`>(
  'VITE_CGS_TOKEN_CONTRACT_ADDRESS',
  import.meta.env.VITE_CGS_TOKEN_CONTRACT_ADDRESS as `0x${string}`
)

const {
  data: tokenContractBalance
} = useReadContract({
  address: tokenContractAddress.value,
  abi: cgsTokenAbi,
  functionName: 'balanceOf' as const,
  args: [ tokenContractAddress.value ],
  query: {
    enabled: computed(() => !!tokenContractAddress.value)
  }
})

const {
  data: isTaxPaused,
  status: isTaxPausedStatus,
  refetch: refetchIsTaxPaused
} = useReadContract({
  address: tokenContractAddress.value,
  abi: cgsTokenAbi,
  functionName: 'isTaxPaused' as const,
  query: {
    enabled: computed(() => !!tokenContractAddress.value)
  }
})

const {
  data: isTaxPermanentlyDisabled,
  status: isTaxPermanentlyDisabledStatus,
  refetch: refetchIsTaxPermanentlyDisabled
} = useReadContract({
  address: tokenContractAddress.value,
  abi: cgsTokenAbi,
  functionName: 'isTaxPermanentlyDisabled' as const,
  query: {
    enabled: computed(() => !!tokenContractAddress.value)
  }
})

const {
  data: taxBuyRate,
  status: taxBuyRateStatus,
  refetch: refetchTaxBuyRate
} = useReadContract({
  address: tokenContractAddress.value,
  abi: cgsTokenAbi,
  functionName: 'taxBuyRate' as const,
  query: {
    enabled: computed(() => !!tokenContractAddress.value)
  }
})

const {
  data: taxSellRate,
  status: taxSellRateStatus,
  refetch: refetchTaxSellRate
} = useReadContract({
  address: tokenContractAddress.value,
  abi: cgsTokenAbi,
  functionName: 'taxSellRate' as const,
  query: {
    enabled: computed(() => !!tokenContractAddress.value)
  }
})

const isTogglingTaxPause = ref(false)
const toggleTaxPause = async (paused: boolean) => {
  if (!tokenContractAddress.value) {
    console.error('No token contract address')
    return
  }

  isTogglingTaxPause.value = true
  console.log('Toggling tax pause to', paused)
  try {
    await writeContractAsync({
      address: tokenContractAddress.value as `0x${string}`,
      abi: cgsTokenAbi,
      functionName: paused ? 'pauseTax' as const : 'unpauseTax' as const
    })
  } catch (err) {
    console.error(
      `Error toggling tax pause on token contract: paused = ${paused}`,
      err
    )
  } finally {
    await refetchIsTaxPaused()
    isTogglingTaxPause.value = false
  }
}

const isPermanentlyDisablingTax = ref(false)
const permanentlyDisableTax = async () => {
  if (!tokenContractAddress.value) {
    console.error('No token contract address')
    return
  }

  isPermanentlyDisablingTax.value = true
  console.log('Permanently disabling tax')
  try {
    await writeContractAsync({
      address: tokenContractAddress.value as `0x${string}`,
      abi: cgsTokenAbi,
      functionName: 'permanentlyDisableTax' as const
    })
  } catch (err) {
    console.error(
      `Error permanently disabling tax on token contract`,
      err
    )
  } finally {
    await refetchIsTaxPermanentlyDisabled()
    isPermanentlyDisablingTax.value = false
  }
}

const isUpdatingTaxRates = ref(false)
const newTaxRate = ref(0)
const updateTaxRate = async (buyOrSell: 'buy' | 'sell') => {
  if (!tokenContractAddress.value) {
    console.error('No token contract address')
    return
  }

  isUpdatingTaxRates.value = true
  console.log(`Updating ${buyOrSell} tax rate to ${newTaxRate.value}`)
  try {
    await writeContractAsync({
      address: tokenContractAddress.value as `0x${string}`,
      abi: cgsTokenAbi,
      functionName: buyOrSell === 'buy'
        ? 'setBuyTaxRate' as const
        : 'setSellTaxRate' as const,
      args: [ethers.parseUnits(newTaxRate.value.toString(), 3)]
    })
  } catch (err) {
    console.error(
      `Error updating ${buyOrSell} tax rate on token contract: rate = ${newTaxRate.value}`,
      err
    )
  } finally {
    if (buyOrSell === 'buy') {
      await refetchTaxBuyRate()
    } else {
      await refetchTaxSellRate()
    }
    isUpdatingTaxRates.value = false
  }
}

const isAddingRemovingNewTaxExemptAddress = ref(false)
const taxExemptAddress = ref('')
const addRemoveTaxExemptAddress = async (addOrRemove: 'add' | 'remove') => {
  if (!tokenContractAddress.value) {
    console.error('No token contract address')
    return
  }

  isAddingRemovingNewTaxExemptAddress.value = true
  console.log('Adding new tax exempt address', taxExemptAddress.value)
  try {
    await writeContractAsync({
      address: tokenContractAddress.value,
      abi: cgsTokenAbi,
      functionName: addOrRemove === 'add'
        ? 'addTaxExemption' as const
        : 'removeTaxExemption' as const,
      args: [ taxExemptAddress.value as `0x${string}` ]
    })
  } catch (err) {
    console.error(
      `Error adding new tax exempt address on token contract: address = ${taxExemptAddress.value}`,
      err
    )
  } finally {
    isAddingRemovingNewTaxExemptAddress.value = false
  }
}

const isAddingRemovingLiquidityProvider = ref(false)
const liquidityProviderAddress = ref('')
const addRemoveLiquidityProvider = async (addOrRemove: 'add' | 'remove') => {
  if (!tokenContractAddress.value) {
    console.error('No token contract address')
    return
  }

  isAddingRemovingLiquidityProvider.value = true
  console.log('Adding new liquidity provider', liquidityProviderAddress.value)
  try {
    await writeContractAsync({
      address: tokenContractAddress.value,
      abi: cgsTokenAbi,
      functionName: addOrRemove === 'add'
        ? 'addLiquidityProvider' as const
        : 'removeLiquidityProvider' as const,
      args: [ liquidityProviderAddress.value as `0x${string}` ]
    })
  } catch (err) {
    console.error(
      `Error adding new liquidity provider on token contract: address = ${liquidityProviderAddress.value}`,
      err
    )
  } finally {
    isAddingRemovingLiquidityProvider.value = false
  }
}
</script>
