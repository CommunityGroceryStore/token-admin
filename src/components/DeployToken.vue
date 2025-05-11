<template>
  <div>
    <div v-if="isConnected">
      <div v-if="tokenContractAddress">
        <p>
          ✔️ Token Contract deployed at
          <strong><code>{{ tokenContractAddress }}</code></strong>
        </p>
      </div>
      <div v-else>
        <p>Token Contract Address not found in config or localstorage</p>
        🔘 <button @click="deployContract" :disabled="deploying">
          {{
            deploying
              ? 'Deploying Token Contract...'
              : 'Deploy New Token Contract'
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
import { cgsTokenAbi } from '@/assets/contract-artifacts/wagmi-generated'
import { CGSTokenBytecode } from '@/assets/contract-artifacts/contract-bytecode'

const { isConnected } = useAccount()
const connectorClient = useConnectorClient()
const deploying = ref(false)
const tokenContractAddress = useStorage(
  'VITE_CGS_TOKEN_CONTRACT_ADDRESS',
  import.meta.env.VITE_CGS_TOKEN_CONTRACT_ADDRESS
)

const deployContract = async () => {
  if (!isConnected.value) { return }
  const signer = getSigner(connectorClient)
  if (!signer) {
    console.log('No signer')
    return
  }

  deploying.value = true
  try {
    const factory = new ethers.ContractFactory(cgsTokenAbi, CGSTokenBytecode)
    const contract = await factory.connect(signer).deploy(
      signer.address,
      ethers.parseUnits('1000000000', 18)
    )
    await contract.waitForDeployment()
    const deployedTokenContractAddress = await contract.getAddress()
    tokenContractAddress.value = deployedTokenContractAddress
  } catch (err) {
    console.error('Deployment failed: ' + (err as Error).message)
  } finally {
    deploying.value = false
  }
}
</script>
