<template>
  <div>
    <div v-if="isConnected">
      <div v-if="usdcContractAddress">
        <p>
          ✔️ $USDC Contract deployed at
          <strong><code>{{ usdcContractAddress }}</code></strong>
        </p>
      </div>
      <div v-else>
        <p>
          $USDC Contract Address not found in config or localstorage
        </p>
        🔘 <button @click="deployMockStablecoin('USDC')" :disabled="deploying">
          {{
            deploying
              ? 'Deploying Mock USDC Contract...'
              : 'Deploy New Mock USDC Contract'
          }}
        </button>
      </div>

      <div v-if="usdtContractAddress">
        <p>
          ✔️ $USDT Contract deployed at
          <strong><code>{{ usdtContractAddress }}</code></strong>
        </p>
      </div>
      <div v-else>
        <p>$USDT Contract Address not found in config or localstorage</p>
        🔘 <button @click="deployMockStablecoin('USDT')" :disabled="deploying">
          {{
            deploying
              ? 'Deploying Mock USDT Contract...'
              : 'Deploy New Mock USDT Contract'
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
import { ethers } from 'ethers'
import { useAccount, useConnectorClient } from '@wagmi/vue'
import { useStorage } from '@vueuse/core'

import { getSigner } from '@/utils/web3'
import { mockStablecoinAbi } from '@/assets/contract-artifacts/wagmi-generated'
import {
  MockStablecoinBytecode
} from '@/assets/contract-artifacts/contract-bytecode'

const { isConnected } = useAccount()
const connectorClient = useConnectorClient()
const deploying = ref(false)
const usdcContractAddress = useStorage(
  'VITE_USDC_CONTRACT_ADDRESS',
  import.meta.env.VITE_USDC_CONTRACT_ADDRESS
)
const usdtContractAddress = useStorage(
  'VITE_USDT_CONTRACT_ADDRESS',
  import.meta.env.VITE_USDT_CONTRACT_ADDRESS
)

const deployMockStablecoin = async (ticker: 'USDC' | 'USDT') => {
  if (!isConnected.value) { return }
  const signer = getSigner(connectorClient)
  if (!signer) {
    console.log('No signer')
    return
  }

  deploying.value = true
  try {
    const factory = new ethers.ContractFactory(
      mockStablecoinAbi,
      MockStablecoinBytecode
    )
    const contract = await factory.connect(signer).deploy(
      ticker,
      ticker,
      ethers.parseUnits('1000000', 6)
    )
    await contract.waitForDeployment()
    const deployedTokenContractAddress = await contract.getAddress()

    if (ticker === 'USDT') {
      usdtContractAddress.value = deployedTokenContractAddress
    } else if (ticker === 'USDC') {
      usdcContractAddress.value = deployedTokenContractAddress
    }
  } catch (err) {
    console.error('Deployment failed: ' + (err as Error).message)
  } finally {
    deploying.value = false
  }
}
</script>
