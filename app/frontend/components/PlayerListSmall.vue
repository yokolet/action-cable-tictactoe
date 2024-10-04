<script setup lang="ts">
import { firstLetter } from '../entrypoints/application.ts';
import { ref } from 'vue';
import FullList from './FullList.vue';

defineProps<{
  players: string[],
  bgColors: string[],
  txColors: string[],
}>();

const openFullList = ref<boolean>(false);
</script>

<template>
  <div class="container flex justify-start w-full px-4 mt-0 md:mt-10 md:pb-4 text-center h-20 md:h-24 bg-slate-600">
    <div class="flex items-center justify-between my-4 space-x-6">
      <div class="text-sm text-white">Players</div>
      <div
          v-for="(player, index) in players.slice(0, 5)"
          class="w-12 h-12 rounded-full border-1 border-beige flex justify-center items-center
        text-2xl hover:text-lightBlue hover:scale-95 has-tooltip"
          :class="bgColors[index % bgColors.length]"
      >
        {{ firstLetter(player) }}
        <span
            class="tooltip bg-slate-700 text-base"
            :class="txColors[index % txColors.length]"
        >{{ player }}</span>
      </div>
      <button
          v-show="players.length > 5"
          @click="openFullList = !openFullList"
          class="hover:text-lightBlue hover:scale-110"
      >
        more...
      </button>
      <FullList
          :open-full-list="openFullList"
          :clickable="false"
          :close-full-list="false"
          :items="players"
          :tx-colors="txColors"
          @close-full-list="openFullList = false"
      />
    </div>
  </div>
</template>

<style scoped>

</style>
