<script setup lang="ts">
import { storeToRefs } from 'pinia';
import { usePlayerStore } from '../stores/player.ts';
import { useBoardStore } from '../stores/board.ts';
import { computed, ref, watch } from 'vue';

const playerStore = usePlayerStore();
const { registered, currentBoardId } = storeToRefs(playerStore);

const boardStore = useBoardStore();
const {
  boardChannel,
  boardName,
  xName,
  oName,
  playResult,
  boardState,
  boardCount,
  boardData,
} = storeToRefs(boardStore);

const displayName = ref<string>('Join or Create Board');

const players = computed(() => {
  let who = ' vs ';
  if (xName.value) {
    who = `X: ${xName.value} ${who}`;
  }
  if (oName.value) {
    who = `${who} O: ${oName.value}`;
  }
  who = `<span>${who}</span>`;
  return who;
});

const winner = computed(() => {
  if (playResult.value === 'x_wins') {
    return `${xName.value} won`;
  } else if (playResult.value === 'o_wins') {
    return `${oName.value} won`;
  } else if (playResult.value === 'draw') {
    return 'Cat Got It!';
  } else {
    return '';
  }
});

watch(
    currentBoardId,
    (newValue, _) => {
      if (newValue) {
        if (currentBoardId.value && boardChannel.value) {
          displayName.value = `${boardName.value} Battle!`;
        } else {
          displayName.value = 'Join or Create Board';
        }
      } else {
        displayName.value = 'Join or Create Board';
      }
    }
)
</script>

<template>
  <div class="container mx-auto flex flex-col items-center justify-center w-full h-full px-4 text-center bg-slate-800">
    <div
        class="mt-4 text-2xl"
        :class="registered ? '' : 'opacity-35'"
    >{{ displayName }}</div>
    <div v-show="currentBoardId" :class="registered ? '' : 'opacity-35'">
      <div
          class="flex items-center justify-center text-xl text-lightBlue"
          v-html="players"></div>
      <div
          v-if="boardState === 'ongoing'"
          class="mb-2 text-spline text-[18px] text-gray-50 pt-4 px-4 rounded-md"
      >
        <div class="bg-gray-900 rounded-md py-1 border border-gray-600">
          <div v-if="boardCount % 2 === 0">
            <font-awesome-icon :icon="['fas', 'xmark']" />'s turn
          </div>
          <div v-else>
            <font-awesome-icon :icon="['fas', 'o']" />'s turn
          </div>
        </div>
      </div>
      <div v-else-if="boardState === 'finished'">
        <h3
            class="mt-4 text-2xl lg:text-4xl font-bold text-gray-50"
        >
          {{ winner }}
        </h3>
      </div>
      <div v-else-if="boardState === 'terminated'">
        Terminated.
      </div>
      <div v-else>Waiting...</div>
    </div>
    <div class="mx-12 md:mx-6 lg:mx-48 mb-4 p-8">
      <div v-for="(row, x) in boardData" :key="x" class="flex">
        <button
            v-for="(cell, y) in row"
            :key="y"
            @click="boardStore.play(currentBoardId, x, y)"
            class="flex items-center justify-center w-24 h-24 text-[52px] bg-slate-700
          border-4 border-slate-800 rounded-xl font-raleway cursor-pointer hover:scale-105
          disabled:opacity-35 disabled:cursor-not-allowed"
            :class="{
        'text-mediumGreen': cell === 'x',
        'text-deepOrange': cell === 'o',
      }"
            :disabled="!registered || !currentBoardId"
        >
          <div v-if="cell === 'x'">
            <font-awesome-icon :icon="['fas', 'xmark']" />
          </div>
          <div v-else-if="cell === 'o'">
            <font-awesome-icon :icon="['fas', 'o']" />
          </div>
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>

</style>
