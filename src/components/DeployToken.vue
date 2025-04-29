<template>
  <div class="max-w-md mx-auto p-6 bg-white rounded-lg shadow-md">
    <h2 class="text-2xl font-bold mb-4">Deploy ERC20 Token</h2>
    
    <form @submit.prevent="handleDeploy" class="space-y-4">
      <!-- Token Name -->
      <div>
        <Label for="tokenName">Token Name</Label>
        <Input
          id="tokenName"
          v-model="tokenName"
          placeholder="e.g., SuperCandy"
          class="w-full"
        />
      </div>

      <!-- Token Symbol -->
      <div>
        <Label for="tokenSymbol">Token Symbol</Label>
        <Input
          id="tokenSymbol"
          v-model="tokenSymbol"
          placeholder="e.g., SCDY"
          class="w-full"
        />
      </div>

      <!-- Initial Supply -->
      <div>
        <Label for="tokenSupply">Initial Supply</Label>
        <Input
          id="tokenSupply"
          v-model="tokenSupply"
          type="number"
          placeholder="e.g., 1000"
          class="w-full"
        />
      </div>

      <!-- Network Selector -->
      <div>
        <Label for="network">Network</Label>
        <Select v-model="selectedNetwork">
          <SelectTrigger>
            <SelectValue placeholder="Select network" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="sepolia">Sepolia Testnet</SelectItem>
            <SelectItem value="mainnet">Ethereum Mainnet</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <!-- Deploy Button -->
      <Button type="submit" :disabled="!isConnected" class="w-full">
        {{ isConnected ? 'Deploy Token' : 'Connect Wallet First' }}
      </Button>
    </form>

    <!-- Deployment Status -->
    <div v-if="deploymentStatus" class="mt-4">
      <p class="text-sm">{{ deploymentStatus }}</p>
      <p v-if="transactionHash" class="text-sm">
        Transaction Hash: 
        <a
          :href="`https://${selectedNetwork === 'sepolia' ? 'sepolia.' : ''}etherscan.io/tx/${transactionHash}`"
          target="_blank"
          class="text-blue-500 underline"
        >
          {{ transactionHash }}
        </a>
      </p>
      <p v-if="tokenAddress" class="text-sm">
        Token Address: {{ tokenAddress }}
      </p>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref } from 'vue'
import { useAccount, useWriteContract } from '@wagmi/vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'

// Form inputs
const tokenName = ref('')
const tokenSymbol = ref('')
const tokenSupply = ref('')
const selectedNetwork = ref('sepolia')

// Wagmi hooks
const { address, isConnected } = useAccount()

// ERC20 contract ABI (shortened for brevity; get full ABI from compiled contract)
const contractAbi = [
  {
    inputs: [
      { name: 'name', type: 'string' },
      { name: 'symbol', type: 'string' },
      { name: 'initialSupply', type: 'uint256' },
    ],
    stateMutability: 'nonpayable',
    type: 'constructor',
  },
  // Add other ERC20 ABI entries as needed
]

// Bytecode (placeholder; replace with actual bytecode from compiled contract)
const contractBytecode = '0x6080604052348015610010...'

// Deployment state
const deploymentStatus = ref('')
const transactionHash = ref('')
const tokenAddress = ref('')

// Deploy function
// const { data: hash, writeContract } = useWriteContract()

async function handleDeploy() {
//   if (!isConnected.value) {
//     deploymentStatus.value = 'Please connect your wallet'
//     return
//   }

//   try {
//     deploymentStatus.value = 'Deploying token...'
//     await deployContract({
//       args: [tokenName.value, tokenSymbol.value, BigInt(tokenSupply.value)],
//       chainId: selectedNetwork.value === 'sepolia' ? 11155111 : 1, // Sepolia or Mainnet
//     })
//   } catch (error: any) {
//     deploymentStatus.value = `Error: ${error.message}`
//   }
}
</script>