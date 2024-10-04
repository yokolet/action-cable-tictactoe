<script setup lang="ts">

import PlayerListSmall from './PlayerListSmall.vue';
import BoardListSmall from './BoardListSmall.vue';
import GamePanel from './GamePanel.vue';
import PlayerListMedium from './PlayerListMedium.vue';
import BoardListMedium from './BoardListMedium.vue';

import { ref } from 'vue';
import { usePlayerStore } from '../stores/player.ts';
import { storeToRefs } from 'pinia';

const playerStore = usePlayerStore();
const { players } = storeToRefs(playerStore);

const bgColors = ref<string[]>([
  'bg-red-600', 'bg-orange-600', 'bg-amber-600', 'bg-yellow-600', 'bg-lime-600', 'bg-green-600',
  'bg-emerald-600', 'bg-teal-600', 'bg-cyan-600',
]);

const txColors = ref<string[]>([
  'text-red-600', 'text-orange-600', 'text-amber-600', 'text-yellow-600', 'text-lime-600', 'text-green-600',
  'text-emerald-600', 'text-teal-600', 'text-cyan-600',
]);

const boards = ref<string[]>([
    'Mario Kart 8', 'Pokémon Omega Ruby', 'Batman: Arkham Asylum', 'BioShock'
]);

const boardBgColors = ref<string[]>([
  'bg-cyan-600', 'bg-sky-600', 'bg-blue-600', 'bg-indigo-600', 'bg-violet-600', 'bg-purple-600',
]);

const boardTxColors = ref<string[]>([
  'text-cyan-600', 'text-sky-600', 'text-blue-600', 'text-indigo-600', 'text-violet-600', 'text-purple-600',
]);
</script>

<template>
  <div class="container mx-auto w-full md:pt-10">
    <div class="grid grid-cols-1 md:grid-cols-12 gap-0">
      <div class="md:hidden">
        <PlayerListSmall
            :players="players"
            :bgColors="bgColors"
            :txColors="txColors"
        />
      </div>
      <div class="hidden md:flex col-span-3">
        <PlayerListMedium
            :players="players"
            :txColors="txColors"
        />
      </div>
      <div class="md:hidden">
        <BoardListSmall
            :boards="boards"
            :boardBgColors="boardBgColors"
            :boardTxColors="boardTxColors"
        />
      </div>
      <div class="flex md:col-span-6">
        <GamePanel />
      </div>
      <div class="hidden md:flex md:col-span-3">
        <BoardListMedium
            :boards="boards"
            :boardBgColors="boardBgColors"
            :boardTxColors="boardTxColors"
        />
      </div>
    </div>
  </div>

</template>

<style>
.tooltip {
  @apply invisible absolute rounded-md shadow-lg p-1 left-1/2 -translate-x-1/2 translate-y-full mx-auto;
}

.has-tooltip:hover .tooltip {
  @apply visible z-50
}
</style>
