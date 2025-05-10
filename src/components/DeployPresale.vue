<template>
  <div>
    <div v-if="isConnected">
      <div v-if="presaleContractAddress">
        <p>
          Presale Contract deployed at
          <strong><code>{{ presaleContractAddress }}</code></strong>
        </p>
      </div>
      <div v-else>
        <p>Presale Contract Address not found in config or localstorage</p>
        <p>
          <label for="presaleVestingDurationInSeconds">
            Vesting Duration (in seconds)
          </label>
          &nbsp;
          <input
            name="presaleVestingDurationInSeconds"
            v-model="presaleVestingDurationInSeconds"
          />
        </p>
        <p>
          <label for="presaleVestingCliffInSeconds">
            Vesting Cliff (in seconds)
          </label>
          &nbsp;
          <input
            name="presaleVestingCliffInSeconds"
            v-model="presaleVestingCliffInSeconds"
          />
        </p>
        <button @click="deployContract" :disabled="deploying">
          {{
            deploying
              ? 'Deploying Presale Contract...'
              : 'Deploy New Presale Contract'
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

import CGSPresaleArtifact
  from '@/assets/contract-artifacts/CGSTokenPresale.json'
import { getSigner } from '@/utils/web3'

const { isConnected } = useAccount()
const connectorClient = useConnectorClient()
const deploying = ref(false)
const presaleContractAddress = useStorage(
  'VITE_CGS_PRESALE_CONTRACT_ADDRESS',
  import.meta.env.VITE_CGS_PRESALE_CONTRACT_ADDRESS
)
const tokenContractAddress = useStorage(
  'VITE_CGS_TOKEN_CONTRACT_ADDRESS',
  import.meta.env.VITE_CGS_TOKEN_CONTRACT_ADDRESS
)
const presaleVestingDurationInSeconds = ref(3600)
const presaleVestingCliffInSeconds = ref(120)

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
      CGSPresaleArtifact.abi,
      CGSPresaleArtifact.bytecode
    )
    const contract = await factory.connect(signer).deploy(
      signer.address,
      tokenContractAddress.value,
      presaleVestingDurationInSeconds.value,
      presaleVestingCliffInSeconds.value
    )
    await contract.waitForDeployment()
    const deployedTokenContractAddress = await contract.getAddress()
    presaleContractAddress.value = deployedTokenContractAddress
  } catch (err) {
    console.error('Deployment failed: ' + (err as Error).message)
  } finally {
    deploying.value = false
  }
}
</script>
