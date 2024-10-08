<script setup lang="ts">
import { useTicTacToeStore } from '../stores/tictactoe';
import { storeToRefs } from 'pinia';
import { usePlayerStore } from '../stores/player.ts';
import { useBoardStore } from '../stores/board.ts';
import { computed, ref, watch } from 'vue';

const store = useTicTacToeStore();
const { player, board, winner, isTie, isOver } = storeToRefs(store);
const playerStore = usePlayerStore();
const { registered, currentBoardId } = storeToRefs(playerStore);

const boardStore = useBoardStore();
const { boardChannel } = storeToRefs(boardStore);

const boardName = ref<string>('Join or Create Board');

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
      <div v-if="!isOver" class="mb-2 text-spline text-[18px] text-gray-50 pt-4 px-4 rounded-md">
        <div v-if="player === 'X'">
          <font-awesome-icon :icon="['fas', 'xmark']" />'s turn
        </div>
        <div v-else-if="player === 'O'">
          <font-awesome-icon :icon="['fas', 'o']" />'s turn
        </div>
      </div>
      <div v-else>
        <h3 v-if="winner" class="mt-4 text-2xl lg:text-4xl font-bold text-gray-50">
          <div v-if="winner === 'X'">
            Player <font-awesome-icon :icon="['fas', 'xmark']" /> wins!
          </div>
          <div v-else-if="winner === 'O'">
            Player <font-awesome-icon :icon="['fas', 'o']" /> wins!
          </div>
        </h3>
        <h3 v-if="isTie" class="mt-4 text-2xl lg:text-4xl font-bold text-gray-50">Cat Got It!</h3>
      </div>
    </div>
    <div class="mx-12 md:mx-6 lg:mx-48 mb-4 p-8">
      <div v-for="(row, x) in board" :key="x" class="flex">
        <button
            v-for="(cell, y) in row"
            :key="y"
            @click="store.updateBoard(x, y)"
            class="flex items-center justify-center w-24 h-24 text-[52px] bg-slate-700
          border-4 border-slate-800 rounded-xl font-raleway cursor-pointer hover:scale-105
          disabled:opacity-35 disabled:cursor-not-allowed"
            :class="{
        'text-mediumGreen': cell === 'X',
        'text-deepOrange': cell === 'O',
      }"
            :disabled="!registered || !currentBoardId"
        >
          <div v-if="cell === 'X'">
            <font-awesome-icon :icon="['fas', 'xmark']" />
          </div>
          <div v-else-if="cell === 'O'">
            <font-awesome-icon :icon="['fas', 'o']" />
          </div>
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>

</style>
