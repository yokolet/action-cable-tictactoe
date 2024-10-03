<script setup lang="ts">
import { firstLetter } from '../entrypoints/application.ts';
import { usePlayerStore } from '../stores/player.ts';
import { storeToRefs } from 'pinia';
import FullList from './FullList.vue';
import { ref } from 'vue';

defineProps<{
  boards: string[],
  boardBgColors: string[],
  boardTxColors: string[],
}>();

const playerStore = usePlayerStore();
const { registered } = storeToRefs(playerStore);

const openFullList = ref<boolean>(false);
</script>

<template>
  <div class="container flex justify-start w-full px-4 mt-0 text-center h-20 bg-slate-700">
    <button
        class="rounded-full bg-slate-900 text-lightBlue my-4 mr-4 px-4 hover:text-white hover:scale-95
        disabled:opacity-35 disabled:cursor-not-allowed"
        :disabled="!registered"
    >
      Create New
    </button>
    <div
        v-show="boards.length > 0"
        class="flex items-center justify-center w-24 mr-4"
    >
      or join <span class="ml-2"><font-awesome-icon :icon="['fas', 'angle-right']" /></span>
    </div>
    <div class="flex items-center justify-between my-4 space-x-6">
      <button
          v-for="(board, index) in boards.slice(0, 3)"
          class="w-12 h-12 rounded-full border-1 border-beige flex justify-center items-center
        text-2xl hover:text-lightBlue hover:scale-95 has-tooltip disabled:opacity-35 disabled:cursor-not-allowed"
          :class="boardBgColors[index % boardBgColors.length]"
          :disabled="!registered"
      >
        {{ firstLetter(board) }}
        <span
            class="tooltip bg-slate-900 text-base"
            :class="boardTxColors[index % boardTxColors.length]"
        >{{ board }}</span>
      </button>
      <button
          v-show="boards.length > 3"
          @click="openFullList = !openFullList"
          class="hover:text-lightBlue hover:scale-110 disabled:opacity-35 disabled:cursor-not-allowed"
          :disabled="!registered"
      >
        more...
      </button>
      <FullList
          :open-full-list="openFullList"
          :clickable="true"
          :items="boards"
          :tx-colors="boardTxColors"
          @close-full-list="openFullList = false"
      />
    </div>
  </div>
</template>

<style scoped>

</style>
