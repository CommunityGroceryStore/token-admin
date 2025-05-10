<template>
  <div>
    <div v-if="isConnected">
      <div v-if="vestingContractAddress">
        <p>
          Vesting Contract deployed at
          <strong><code>{{ vestingContractAddress }}</code></strong>
        </p>
      </div>
      <div v-else>
        <p>Vesting Contract Address not found in config or localstorage</p>
        <button @click="deployContract" :disabled="deploying">
          {{
            deploying
              ? 'Deploying Vesting Contract...'
              : 'Deploy New Vesting Contract'
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

import CGSVestingArtifact from '@/assets/contract-artifacts/CGSVesting.json'
import { getSigner } from '@/utils/web3'

const { isConnected } = useAccount()
const connectorClient = useConnectorClient()
const deploying = ref(false)
const vestingContractAddress = useStorage(
  'VITE_CGS_VESTING_CONTRACT_ADDRESS',
  import.meta.env.VITE_CGS_PRESALE_CONTRACT_ADDRESS
)
const tokenContractAddress = useStorage(
  'VITE_CGS_TOKEN_CONTRACT_ADDRESS',
  import.meta.env.VITE_CGS_TOKEN_CONTRACT_ADDRESS
)

const deployContract = async () => {
  if (!isConnected.value) { return }
  if (!tokenContractAddress.value) {
    console.error('No token contract address')
    return
  }
  const signer = getSigner(connectorClient)
  if (!signer) {
    console.error('No signer')
    return
  }

  deploying.value = true
  try {
    const factory = new ethers.ContractFactory(
      CGSVestingArtifact.abi,
      CGSVestingArtifact.bytecode
    )
    const contract = await factory.connect(signer).deploy(
      signer.address,
      tokenContractAddress.value
    )
    await contract.waitForDeployment()
    const deployedTokenContractAddress = await contract.getAddress()
    vestingContractAddress.value = deployedTokenContractAddress
  } catch (err) {
    console.error('Deployment failed: ' + (err as Error).message)
  } finally {
    deploying.value = false
  }
}
</script>
