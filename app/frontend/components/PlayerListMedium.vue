<script setup lang="ts">
defineProps<{
  players: string[],
  txColors: string[],
}>();
</script>

<template>
<div class="flex flex-col">
  <div class="text-center text-lg lg:text-xl">Current Players</div>
  <div v-for="(player, index) in players">
    <div
        class="flex flex-cols items-center justify-start py-4 text-lg"
        :class="txColors[index % txColors.length]"
    >
      {{ player }}
    </div>
  </div>
</div>
</template>

<style scoped>

</style>
