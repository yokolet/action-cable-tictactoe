<script setup lang="ts">
import { usePlayerStore } from '../stores/player.ts';
import { storeToRefs } from 'pinia';
import Registration from './Registration.vue';
import { ref, watch } from 'vue';

const playerStore = usePlayerStore();
const { registered, playerName } = storeToRefs(playerStore);
const openRegistration = ref<boolean>(false);

const toggleRegistration = () => {
  if (registered.value) {
    playerStore.removePlayer();
  } else {
    openRegistration.value = true;
  }
}

watch(
    registered,
    (newValue, _) => {
      if (newValue) {
        openRegistration.value = false;
      }
    }
)
</script>

<template>
  <Registration
      :open-registration="openRegistration"
      @close-registration="openRegistration = false"
  />
  <header class="container mx-auto pt-10 px-6 text-center h-40 md:h-20">
    <div class="flex justify-start text-2xl md:text-4xl font-bold">
      Tic Tac Toe
    </div>
    <div class="flex items-center justify-end space-x-4 md:text-lg md:space-x-10 md:absolute top-12 right-10">
      <div
          v-if="registered"
          class="hover:text-lightBlue"
      >
        <span class="text-base"><font-awesome-icon :icon="['fas', 'user']" /></span>
        {{ playerName }}
      </div>
      <div
          v-else
          class="hover:text-lightBlue"
      >Register to Play</div>
      <button
          @click="toggleRegistration"
          class="p-2 rounded-full w-32 bg-slate-600 hover:text-lightBlue hover:scale-95"
      >
        {{ registered ? 'Unregister' : 'Register' }}
      </button>
    </div>
  </header>
</template>

<style scoped>

</style>
