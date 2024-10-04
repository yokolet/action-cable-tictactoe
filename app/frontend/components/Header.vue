<script setup lang="ts">
import { usePlayerStore } from '../stores/player.ts';
import { storeToRefs } from 'pinia';
import Registration from '~/components/Registration.vue';
import { ref } from 'vue';

const playerStore = usePlayerStore();
const { registered } = storeToRefs(playerStore);
const openRegistration = ref<boolean>(false);

const toggleRegistration = () => {
  registered.value = !registered.value;
  openRegistration.value = !openRegistration.value;
}
</script>

<template>
  <Registration
      :open-registration="!openRegistration"
      @close-registration="toggleRegistration"
  />
  <header class="container mx-auto pt-10 px-6 text-center h-40 md:h-20">
    <div class="flex justify-start text-2xl md:text-4xl font-bold">
      Tic Tac Toe
    </div>
    <div class="flex items-center justify-end space-x-4 md:text-lg md:space-x-10 md:absolute top-12 right-10">
      <div
          v-show="registered"
          class="hover:text-lightBlue"
      >
        <span class="text-base"><font-awesome-icon :icon="['fas', 'user']" /></span>
        Alice
      </div>
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
