<template>
    <div v-if="isConnected">
        <h1>Dashboard</h1>
    </div>
    <div class="connect-wallet-container" v-else>
        <Button @click="open({ view: 'Connect', namespace: 'eip155' })">
            Connect wallet
        </Button>
    </div>
</template> 

<style scoped>
.connect-wallet-container {
    width: 100%;
    height: 100%;
    display: grid;
    place-items: center;
}
</style>

<script lang="ts" setup>
import { useAppKit } from "@reown/appkit/vue";
import Button from "./ui/button/Button.vue";
import { useAccount } from "@wagmi/vue";

const { open } = useAppKit()
const { isConnected } = useAccount()
</script>