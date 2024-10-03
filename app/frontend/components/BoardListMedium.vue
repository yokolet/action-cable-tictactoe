<script setup lang="ts">
import { usePlayerStore } from '../stores/player.ts';
import { storeToRefs } from 'pinia';

defineProps<{
  boards: string[],
  boardBgColors: string[],
  boardTxColors: string[],
}>();

const playerStore = usePlayerStore();
const { registered } = storeToRefs(playerStore);
</script>

<template>
  <div class="flex flex-col items-center justify-center ml-8 mb-8">
    <div class="text-lg lg:text-xl">Current Boards</div>
    <button
        class="rounded-full bg-slate-900 text-lightBlue md:text-md lg:text-lg my-4 mr-4 py-2 px-6 hover:text-white
        hover:scale-95 disabled:opacity-35 disabled:cursor-not-allowed"
        :disabled="!registered"
    >
      Create New
    </button>
    <div class="flex flex-col items-center justify-center w-24 mr-4 text-xl">
      <div class="text-white">
        or join
      </div>
      <div><span><font-awesome-icon :icon="['fas', 'angle-down']" /></span></div>
    </div>
    <div
        v-for="(board, index) in boards"
        class="group flex flex-col">
      <button
          class="py-4 text-lg hover:scale-110 disabled:opacity-35 disabled:cursor-not-allowed"
          :class="boardTxColors[index % boardTxColors.length]"
          :disabled="!registered"
      >
        {{ board }}
      </button>
      <div class="mx-2 group-hover:border-b group-hover:border-lightBlue"></div>
    </div>
  </div>
</template>

<style scoped>

</style>
