<script setup lang="ts">
import { storeToRefs } from 'pinia';
import { usePlayerStore } from '../stores/player.ts';
import { useBoardStore } from '../stores/board.ts';
import { computed, ref, watch } from 'vue';

const playerStore = usePlayerStore();
const { registered, currentBoardId } = storeToRefs(playerStore);

const boardStore = useBoardStore();
const { x_name, o_name, boardChannel } = storeToRefs(boardStore);

const boardName = ref<string>('Join or Create Board');

const players = computed(() => {
  let who = ' VS ';
  if (x_name.value) {
    who = `X: ${x_name.value} ${who}`;
  }
  if (o_name.value) {
    who = `${who} O: ${o_name.value}`;
  }
  return who;
});

const winner = computed(() => {
  if (boardChannel.value['playResult'] === 'x_wins') {
    return `${x_name.value} won`;
  } else if (boardChannel.value['playResult'] === 'o-wins') {
    return `${o_name.value} won`;
  } else if (boardChannel.value['playResult'] === 'draw') {
    return 'Cat Got It!';
  } else {
    return '';
  }
});

watch(
    currentBoardId,
    (newValue, oldValue) => {
      console.log('GamePanel, newValue', newValue);
      console.log('GamePanel, oldValue', oldValue);
      if (newValue) {
        console.log('GamePanel currentBoardId', currentBoardId.value);
        console.log('GamePanel, boardChannel', boardChannel.value);
        if (currentBoardId.value && boardChannel.value) {
          boardName.value = `${boardChannel.value['name']} Battle!`;
        } else {
          boardName.value = 'Join or Create Board';
        }
      } else {
        boardName.value = 'Join or Create Board';
      }
    }
)
</script>

<template>
  <div class="container mx-auto flex flex-col items-center justify-center w-full h-full px-4 text-center bg-slate-800">
    <div
        v-if="registered"
        class="mt-4 text-2xl"
    >{{ boardName }}</div>
    <div v-show="currentBoardId">
      <div class="flex items-center justify-center text-xl"><span v-html="players"></span></div>
      <div
          v-if="boardChannel['boardState'] === 'ongoing'"
          class="mb-2 text-spline text-[18px] text-gray-50 pt-4 px-4 rounded-md"
      >
        <div>
          <div v-if="boardChannel['boardCount'] % 2 === 0">
            <font-awesome-icon :icon="['fas', 'xmark']" />'s turn
          </div>
          <div v-else>
            <font-awesome-icon :icon="['fas', 'o']" />'s turn
          </div>
        </div>
      </div>
      <div
          v-else
      >
        <h3 class="mt-4 text-2xl lg:text-4xl font-bold text-gray-50">
          {{ winner }}
        </h3>
      </div>
    </div>
    <div class="mx-12 md:mx-6 lg:mx-48 mb-4 p-8">
      <div v-for="(row, x) in boardChannel['boardData']" :key="x" class="flex">
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
