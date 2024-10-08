import { defineStore, storeToRefs } from 'pinia';
import { createConsumer } from '@rails/actioncable';
import { ref } from 'vue';
import { usePlayerStore } from './player.ts';

interface IData {
  action: string;
  status: string;
  message?: string;
  boards?: string[][];
  name?: string;
  bid?: string;
}

interface IChannel {
  channel: any;
  bid: string;
  name: string;
  boardData: string[][];
}

const playerStore = usePlayerStore();
const { currentBoardId } = storeToRefs(playerStore);

export const useBoardStore = defineStore('board', () => {
  const boardChannel = ref<IChannel>({});
  const message = ref<string>('');

  const createBoardChannel = (boardId: string) => {
    return createConsumer()
      .subscriptions
      .create({ channel: 'BoardChannel', board_id: boardId }, {
        received(data: IData) {
          console.log('BoardStore received data', data);
          if (data['action'] === 'board:action:subscribed') {
            afterSubscribed(boardId, data);
          } else if (data['action'] === 'board:action:leave') {
            afterLeave(boardId, data);
          }
        }
      });
  }

  const afterSubscribed = (boardId: string, data: IData) => {
    if (data['status'] === 'board:status:success' && boardId === data['bid']) {
      message.value = '';
      boardChannel.value['boardId'] = data['bid'];
      boardChannel.value['name'] = data['name'];
      boardChannel.value['boardData'] = data['board']; // a game might be ongoing already
      currentBoardId.value = data['bid'];
      console.log('afterSubscribed', boardId, boardChannel.value['channel'], boardChannel.value['name']);
    } else {
      message.value = data['message'] || 'Something went wrong';
    }
  }

  const afterLeave = (data: IData) => {
    if (data['status'] === 'board:status:error') {
      message.value = data['message'] || 'Something went wrong';
    } else if (data['status'] === 'board:status:success') {
      currentBoardId.value = '';
      boardChannel.value = {};
    }
  }

  const joinBoard = (boardId: string) => {
    boardChannel.value["channel"] = createBoardChannel(boardId);
  }

  return { message, boardChannel, joinBoard };
});
