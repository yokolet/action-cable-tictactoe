<script setup lang="ts">
import { useBoardStore } from '../stores/board.ts';

defineProps<{
  items: string[] | string[][],
  txColors: string[],
  openFullList: boolean,
  clickable: boolean,
}>();

const emit = defineEmits(['closeFullList']);

const boardStore = useBoardStore();

const joinBoard = (item: string | string[]) => {
  if (typeof item === 'object') {
    console.log(`joined to board: ${item[1]}, id: ${item[0]}`);
    boardStore.joinBoard(item[0]);
  }
}
</script>

<template>
  <div
      v-show="openFullList"
      id="menu"
      class="absolute flex p-6 rounded-lg bg-slate-900 opacity-90 left-6 right-6 top-10 z-100">
    <div class="flex flex-col items-center justify-center w-full space-y-6 font-bold text-white rounded-sm">
      <button
          @click="emit('closeFullList')"
          class="absolute top-5 right-5 text-lightBlue hover:text-white hover:scale-110"
      >
        <span class="text-2xl"><font-awesome-icon :icon="['far', 'circle-xmark']" /></span>
      </button>
      <div
          v-for="(item, index) in items"
          class="group"
      >
        <button
            @click="joinBoard(item)"
            class="w-full text-center"
            :class="txColors[index]"
        >
          {{ typeof item === "string" ? item : item[1] }}
        </button>
        <div
            v-show="clickable"
            class="mx-2 group-hover:border-b group-hover:border-lightBlue"
        ></div>
      </div>
    </div>
  </div>
</template>

<style scoped>

</style>
