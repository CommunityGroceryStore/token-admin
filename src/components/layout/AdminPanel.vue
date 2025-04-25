<template>
  <div class="flex flex-col min-h-screen border-r bg-muted/40 w-64">
    <div class="p-6">
      <h2 class="text-lg font-semibold tracking-tight">
        <a href="/"> ERC20 Admin </a>
      </h2>
    </div>

    <div class="flex-1 px-3 py-2">
      <nav class="space-y-1">
        <NuxtLink v-for="r in routes" :key="r.href" :to="r.href">
          <Button
            variant="ghost"
          >
            <component :is="r.icon" class="mr-2 h-5 w-5" />
            {{ r.title }}
          </Button>
        </NuxtLink>
      </nav>
    </div>

    <div class="p-4 border-t">
      <div class="flex items-center gap-3">
        <div class="w-8 h-8 rounded-full bg-primary" />
        <div>
          <p class="text-sm font-medium">Admin User</p>
          <p class="text-xs text-muted-foreground">
            {{ address }}
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { Button } from '@/components/ui/button'
import { FileText, Vote } from 'lucide-vue-next'

const address = ref('No connected user')

// onMounted(() => {
//   console.log(authorized.value)
// })

const routes = [
  {
    href: '/stories',
    icon: FileText,
    title: 'Deploy'
  }
  // {
  //   href: '/votes',
  //   icon: Vote,
  //   title: 'Votes'
  // }
]
</script>
