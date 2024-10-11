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
  player_type: string;
  player_name: string;
  play_result: string;    // go_next, x_wins, o_wins, draw
  board_state: string;    // waiting, ongoing, or finished
  board_count: number;
  board_data: string[][];
}

interface IChannel {
  channel: any;
  bid: string;
  name: string;
  boardState: string;
  boardCount: number;
  boardData: string[][];
  playResult: string;
}

const playerStore = usePlayerStore();
const { currentBoardId } = storeToRefs(playerStore);

export const useBoardStore = defineStore('board', () => {
  const boardChannel = ref<IChannel>({
    channel: null,
    bid: '',
    name: 'Join or Create Board',
    boardState: '',
    boardCount: 0,
    boardData: [
      ['', '', ''],
      ['', '', ''],
      ['', '', ''],
    ],
    playResult: '',
  });
  const x_name = ref<string>('');
  const o_name = ref<string>('');
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
      boardChannel.value['name'] = data['name'];
      boardChannel.value['bid'] = data['bid'];
      boardChannel.value['boardState'] = data['board_state'];
      boardChannel.value['boardData'] = data['board_data']; // a game might be ongoing already
      currentBoardId.value = data['bid'];
      console.log('afterSubscribed', bid, boardChannel.value['channel'], boardChannel.value['name']);
      boardChannel.value['channel'].perform(
        'heads_up',
        {
          message: `A new player joined to ${data['name']}.`,
          bid: bid
        });
    } else {
      message.value = data['message'] || 'Something went wrong';
    }
  }

  const afterPlay = (boardId: string, data: IData) => {
    if (data['status'] === 'board:status:success' && boardId === data['bid']) {
      message.value = '';
      boardChannel.value['playResult'] = data['play_result'];
      boardChannel.value['boardCount'] = data['board_count'];
      boardChannel.value['boardData'] = data['board_data'];
    } else {
      message.value = data['message'] || 'Something went wrong';
    }
  }

  const afterHowdy = (boardId: string, data: IData) => {
    console.log('afterHowdy ', data);
    if (data['status'] === 'board:status:success' && boardId === data['bid']) {
      switch(data['player_type']) {
        case 'playing_x':
          x_name.value = data['player_name'];
          break;
        case 'playing_o':
          o_name.value = data['player_name']
          break;
        default:
          viewers.value.push(data['player_name'])
      }
    }
  }

  const joinBoard = (bid: string) => {
    boardChannel.value["channel"] = createBoardChannel(bid);
  }

  const play = (bid: string, x: number, y: number) => {
    boardChannel.value["channel"].perform("play", {bid: bid, x: x, y: y});
  }

  return { x_name, o_name, viewers, message, boardChannel, joinBoard, play };
});
