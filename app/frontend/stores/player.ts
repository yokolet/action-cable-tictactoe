import { defineStore } from 'pinia';
import { useStorage } from '@vueuse/core';
import { createConsumer } from '@rails/actioncable';
import { ref } from 'vue';

interface IPlayers {
  [key: string]: string[];
}

export const usePlayerStore = defineStore('player', () => {
  const registered = useStorage('registered-player', false, sessionStorage);
  const players = ref<string[]>([]);
  const player = ref<string>('');
  const message = ref<string>('');

  const channel = createConsumer().subscriptions.create({ channel: 'PlayerChannel' }, {
    received(data: IPlayers) {
      console.log('Received data', data);
      players.value = data["players"]
    }
  });

  const addPlayer = () => {
    if (player.value === null || player.value.length === 0) {
      message.value = 'Player name is required';
      return;
    }
    channel.perform("register", {"player": player.value });
  }

  const removePlayer = () => {
    channel.perform("unregister", {"player": player.value });
  }

  return { registered, players, addPlayer, removePlayer }
});
