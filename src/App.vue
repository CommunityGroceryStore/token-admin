<script setup lang="ts">
import { RouterView } from 'vue-router';
import AdminPanel from './components/layout/AdminPanel.vue';

</script>

<template>
  <div class="flex min-h-screen">
    <AdminPanel />
    <div class="p-6 w-full">
        <RouterView />
      </div>
  </div>
</template>

<style>
@import '@/style.css';
</style>
