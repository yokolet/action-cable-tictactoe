<script setup lang="ts">
import { usePlayerStore } from '../stores/player.ts';
import { storeToRefs } from 'pinia';

defineProps<{
  openRegistration: boolean,
}>();

const emit = defineEmits(['closeRegistration']);

const playerStore = usePlayerStore();
const { message, playerName } = storeToRefs(playerStore);
const register = () => {
  console.log('playerName', playerName.value);
  playerStore.addPlayer();
}
</script>

<template>
  <div
      v-show="openRegistration"
      class="absolute inset-x-0 p-6 rounded-lg bg-slate-900 left-6 right-6 top-20 md:top-16 z-50"
  >
    <div class="flex flex-col items-center justify-center w-full space-y-6 font-bold text-white rounded-sm">
      <button
          class="absolute right-2 md:right-32 top-1 md:top-4 text-lightBlue p-2 hover:text-white hover:scale-110 text-2xl md:text-3xl"
          @click="emit('closeRegistration')"
      >
        <span class=""><font-awesome-icon :icon="['far', 'circle-xmark']" /></span>
      </button>
      <h3
          class="flex items-center justify-center w-full text-teal-100 p-4 text-lg"
      >
        Register Player Name <span class="pl-4 text-sm text-teal-400">Case Insensitive</span>
      </h3>
      <form @submit.prevent="register">
        <input
            ref="nameInput"
            type="text"
            name="name"
            id="name"
            v-model="playerName"
            class="w-full h-12 px-2 bg-gray-100 text-veryDarkBlue text-lg rounded-md"
        />
        <button
            type="submit"
            class="w-full my-6 px-4 py-2 bg-gray-700 text-deepBeige font-bold rounded-md hover:scale-95"
        >
          Register
        </button>
      </form>
      <div
          v-if="message"
          class="text-rose-400 text-lg rounded-md p-2 h-8"
      >
        {{ message }}
      </div>
    </div>
  </div>
</template>

<style scoped>
</style>
