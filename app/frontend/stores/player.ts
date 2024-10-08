import { defineStore } from 'pinia';
import { useStorage } from '@vueuse/core';
import { createConsumer } from '@rails/actioncable';
import { ref } from 'vue';

interface IData {
  action: string;
  status: string;
  message?: string;
  players?: string[];
}

export const usePlayerStore = defineStore('player', () => {
  const registered = useStorage('tictactoe-player-registered', false, sessionStorage);
  const playerName = useStorage('registered-player-name', '', sessionStorage);
  const players = ref<string[]>([]);
  const message = ref<string>('');
  const currentBoardId = ref<string>('');

  const channel = createConsumer()
    .subscriptions
    .create({ channel: 'PlayerChannel', player: playerName.value }, {
    received(data: IData) {
      console.log('Received data', data);
      if (data['action'] === 'player:action:subscribed') {
        afterSubscribed(data);
      } else if (data['action'] === 'player:action:register') {
        afterAddPlayer(data);
      } else if (data['action'] === 'player:action:unregister') {
        afterRemovePlayer(data);
      } else {
        players.value = data["players"] ? data["players"] : [];
      }
    }
  });

  const afterSubscribed = (data: IData) => {
    if (data['status'] === 'player:status:error' || data['status'] === 'player:status:non-existing') {
      registered.value = false;
      playerName.value = '';
    } else if (data['status'] === 'player:status:existing') {
      registered.value = true;
    }
    players.value = data["players"] ? data["players"] : [];
  }

  const addPlayer = () => {
    if (playerName.value === null || playerName.value.length === 0) {
      message.value = 'Player name is required';
      return;
    }
    channel.perform("register", {"player": playerName.value });
  }

  const afterAddPlayer = (data: IData) => {
    if (data['status'] === 'player:status:error' || data['status'] === 'player:status:retry') {
      message.value = data['message'] ? data['message'] : 'Something went wrong';
    } else if (data['status'] === 'player:status:success') {
      registered.value = true;
      message.value = '';
      channel.perform("heads_up", {"action": "player:action:howdy", "message": `${playerName.value} has joined.` });
    }
  }

  const removePlayer = () => {
    channel.perform("unregister", {});
  }

  const afterRemovePlayer = (data: IData) => {
    if (data['status'] === 'player:status:error') {
      message.value = data['message'] || 'Something went wrong';
    } else if (data['status'] === 'player:status:success') {
      channel.perform("heads_up", {"action": "player:action:goodbye", "message": `${playerName.value} has left.` });
      registered.value = false;
      playerName.value = '';
      message.value = '';
    }
  }

  return { registered, message, players, playerName, currentBoardId, addPlayer, removePlayer }
});
