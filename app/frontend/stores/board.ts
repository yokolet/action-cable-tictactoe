import { defineStore, storeToRefs } from 'pinia';
import { createConsumer } from '@rails/actioncable';
import { ref } from 'vue';
import { usePlayerStore } from './player.ts';

interface IData {
  action: string;
  status: string;
  message?: string;
  bid: string;
  name: string;
  x_name: string;
  o_name: string;
  player_type: string;
  player_name: string;
  play_result: string;    // go_next, x_wins, o_wins, or draw
  board_state: string;    // waiting, ongoing, or finished
  board_count: number;
  board_data: string[][];
}

const playerStore = usePlayerStore();
const { currentBoardId } = storeToRefs(playerStore);

export const useBoardStore = defineStore('board', () => {
  const boardChannel = ref<any>(null);
  const boardName = ref<string>('');
  const xName = ref<string>('');
  const oName = ref<string>('');
  const playResult = ref<string>('');
  const boardState = ref<string>('');
  const boardCount = ref<number>(0);
  const boardData = ref<string[][]>([
    ['', '', ''],
    ['', '', ''],
    ['', '', ''],
  ]);
  const viewers = ref<string[]>([]);
  const message = ref<string>('');

  const createBoardChannel = (bid: string) => {
    return createConsumer()
      .subscriptions
      .create({ channel: 'BoardChannel', board_id: bid }, {
        received(data: IData) {
          console.log('BoardStore received data', data);
          if (data['action'] === 'board:action:subscribed') {
            afterSubscribed(bid, data);
          } else if (data['action'] === 'board:action:play') {
            afterPlay(bid, data);
          } else if (data['action'] === 'board:action:heads_up') {
            afterHowdy(bid, data);
          }
        }
      });
  }

  const afterSubscribed = (bid: string, data: IData) => {
    if (data['status'] === 'board:status:success' && bid === data['bid']) {
      message.value = '';
      boardName.value = data['name'];
      xName.value = data['x_name'];
      oName.value = data['o_name'];
      playResult.value = data['play_result'];
      boardState.value = data['board_state'];
      boardCount.value = data['board_count'];
      boardData.value = data['board_data']; // a game might be ongoing already
      currentBoardId.value = data['bid'];

      console.log('afterSubscribed', boardChannel.value, boardName.value);
      boardChannel.value.perform(
        'heads_up',
        {
          act: 'board:action:howdy',
          message: `A new player joined to ${data['name']}.`,
          bid: bid
        });
    } else {
      message.value = data['message'] || 'Something went wrong';
    }
  }

  const afterPlay = (boardId: string, data: IData) => {
    console.log('afterPlay, data', data);
    if (data['status'] === 'board:status:success' && boardId === data['bid']) {
      message.value = '';
      playResult.value = data['play_result'];
      boardState.value = data['board_state'];
      boardCount.value = data['board_count'];
      boardData.value = data['board_data'];
    } else {
      message.value = data['message'] || 'Something went wrong';
    }
  }

  const afterHowdy = (boardId: string, data: IData) => {
    console.log('afterHowdy ', data);
    if (data['status'] === 'board:status:success' && boardId === data['bid']) {
      boardState.value = data['board_state'];
      switch(data['player_type']) {
        case 'playing_x':
          xName.value = data['player_name'];
          break;
        case 'playing_o':
          oName.value = data['player_name']
          break;
        default:
          viewers.value.push(data['player_name'])
      }
    } else {
      message.value = data['message'] || 'Something went wrong';
    }
  }

  const joinBoard = (bid: string) => {
    boardChannel.value = createBoardChannel(bid);
  }

  const play = (bid: string, x: number, y: number) => {
    boardChannel.value.perform("play", {bid: bid, x: x, y: y});
  }

  const leave = () => {
    boardChannel.value.perform("leave");
  }

  return { boardChannel, boardName, xName, oName, playResult, boardState, boardCount, boardData,
    viewers, message, joinBoard, play, leave };
});
