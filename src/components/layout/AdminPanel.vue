<template>
  <div class="flex flex-col min-h-screen border-r bg-muted/40 w-64">
    <div class="p-6">
      <h2 class="text-lg font-semibold tracking-tight">
        <a href="/"> ERC20 Admin </a>
      </h2>
    </div>

    <div class="flex-1 px-3 py-2">
      <nav class="space-y-1">
        <RouterLink
          v-for="r in routes"
          :key="r.href"
          v-bind="$props"
          :to="isConnected ? r.href : ''"
          custom
          v-slot="{ href, navigate }"
        >
          <a
            v-bind="$attrs"
            :href="isConnected ? href : undefined"
            @click="navigate"
            :role="isConnected ? 'none' : 'link'"
            :aria-disabled="isConnected ? 'false' : 'true'"
          >
            <Button variant="ghost" :disabled="!isConnected">
              <component :is="r.icon" class="mr-2 h-5 w-5" />
              {{ r.title }}
            </Button>
          </a>
        </RouterLink>
      </nav>
    </div>

    <div class="p-4 border-t">
      <div class="flex items-center gap-3">
        <div class="w-8 h-8 rounded-full bg-primary" />
        <div>
          <p class="text-sm font-medium">Admin User</p>
          <p class="text-xs text-muted-foreground">
            {{ walletAddress }}
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Button } from '@/components/ui/button'
import { LayoutDashboard, Rocket } from 'lucide-vue-next'
import { RouterLink } from 'vue-router'
import { abbreviateAddress } from '@/utils'
import { useAccount } from '@wagmi/vue'

const { address, isConnected } = useAccount()

const walletAddress = computed(() =>
  address.value
    ? abbreviateAddress({ address: address.value })
    : 'No connected user'
)

const routes = [
  {
    href: '/',
    icon: LayoutDashboard,
    title: 'Dashboard'
  },
  {
    href: '/deploy',
    icon: Rocket,
    title: 'Deploy'
  }
]
</script>
