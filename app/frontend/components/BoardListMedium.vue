<script setup lang="ts">
import { usePlayerStore } from '../stores/player.ts';
import { storeToRefs } from 'pinia';
import BoardForm from '../components/BoardForm.vue';
import { useBoardListStore } from '../stores/boadlist.ts';

defineProps<{
  boardBgColors: string[],
  boardTxColors: string[],
}>();

const playerStore = usePlayerStore();
const { registered } = storeToRefs(playerStore);
const boardListStore = useBoardListStore();
const { boards, openBoardForm } = storeToRefs(boardListStore);

const joinBoard = (boardId: string) => {
  console.log(`joined to board: ${boardId}`);
}
</script>

<template>
  <BoardForm />
  <div class="flex flex-col items-center justify-center ml-8 mb-8">
    <div class="text-lg lg:text-xl">Current Boards</div>
    <button
        @click="openBoardForm = true"
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
          @click="joinBoard(board[0])"
          class="py-4 text-lg hover:scale-110 disabled:opacity-35 disabled:cursor-not-allowed"
          :class="boardTxColors[index % boardTxColors.length]"
          :disabled="!registered"
      >
        {{ board[1] }}
      </button>
      <div class="mx-2 group-hover:border-b group-hover:border-lightBlue"></div>
    </div>
  </div>
</template>

<style scoped>

</style>
