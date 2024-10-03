import { defineStore } from 'pinia';
import { useStorage } from '@vueuse/core'

export const usePlayerStore = defineStore('player', () => {
  const registered = useStorage('registered-player', false, sessionStorage);

  return { registered }
});
