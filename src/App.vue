<template>
  <header>
    <a href="#" @click="page = 'home'">Deploy</a>
    |
    <a href="#" @click="page = 'token'">Token</a>
    |
    <a href="#" @click="page = 'vesting'">Vesting</a>
    |
    <a href="#" @click="page = 'presale'">Presale</a>
    <br />
    <section>
      <Account v-if="isConnected" />
      <Connect v-else />
    </section>
  </header>
  <hr />
  <main>
    <section v-if="page === 'home'">
      <DeployFlow />
    </section>
    <section v-else-if="page === 'token'">
      <TokenManagement />
    </section>
    <section v-else-if="page === 'vesting'">
      <VestingManagement />
    </section>
    <section v-else-if="page === 'presale'">
      <PresaleManagement />
    </section>
    <section v-else>
      <h1>404</h1>
    </section>
  </main>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useAccount } from '@wagmi/vue'

import Account from '@/components/Account.vue'
import Connect from '@/components/Connect.vue'
import DeployFlow from '@/components/DeployFlow.vue'
import TokenManagement from '@/components/TokenManagement.vue'
import VestingManagement from '@/components/VestingManagement.vue'
import PresaleManagement from '@/components/PresaleManagement.vue'

const page = ref('home')
const { isConnected } = useAccount()
</script>
