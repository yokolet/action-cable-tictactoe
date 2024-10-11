import { defineStore } from 'pinia';
import { createConsumer } from '@rails/actioncable';
import { ref } from 'vue';
import { v4 as uuidv4 } from 'uuid';
import { useBoardStore } from './board.ts';

interface IData {
  action: string;
  status: string;
  message?: string;
  bid: string;
  boards?: string[][];
}

const boardStore = useBoardStore();

export const useBoardListStore = defineStore('board-list', () => {
  const boards = ref<string[][]>([]);
  const boardName = ref<string>('');
  const message = ref<string>('');
  const openBoardForm = ref<boolean>(false);

  const channel = createConsumer()
    .subscriptions
    .create({ channel: 'BoardListChannel' }, {
      received(data: IData) {
        console.log('BoardListStore received data', data);
        if (data['action'] === 'board-list:action:subscribed') {
          afterSubscribed(data);
        } else if (data['action'] === 'board-list:action:create') {
          afterCreateBoard(data);
        } else if (data['action'] === 'board-list:action:delete') {
          afterDeleteBoard(data);
        } else {
          boards.value = data["boards"] || [];
        }
      }
    });

  const afterSubscribed = (data: IData) => {
    if (data['status'] === 'board-list:status:error') {
      message.value = data['message'] || 'Something went wrong';
    } else if (data['status'] === 'board-list:status:success') {
      boards.value = data["boards"] || [];
    }
  }

  const createBoard = () => {
    if (boardName.value === null || boardName.value.length === 0) {
      message.value = 'Board name is required';
      return;
    }
    channel.perform("create_board", {"board_id": uuidv4(), "board_name": boardName.value});
  }

  const afterCreateBoard = (data: IData) => {
    if (data['status'] === 'board-list:status:error' || data['status'] === 'board-list:status:retry') {
      message.value = data['message'] ? data['message'] : 'Something went wrong';
    } else if (data['status'] === 'board-list:status:success') {
      channel.perform(
        "heads_up",
        { "action": "board-list:action:howdy", "message": `${boardName.value} has been created.` });
      boardName.value = '';
      message.value = '';
      openBoardForm.value = false;
      boardStore.joinBoard(data['bid']);
    }
  }

  const deleteBoard = () => {
    channel.perform("delete_board", {});
  }

  const afterDeleteBoard = (data: IData) => {
    if (data['status'] === 'board-list:status:error') {
      message.value = data['message'] || 'Something went wrong';
    } else if (data['status'] === 'board-list:status:success') {
      channel.perform("heads_up", {"action": "board-list:action:goodbye", "message": `${boardName.value} was deleted.` });
      boardName.value = '';
      message.value = '';
    }
  }

  return { message, boards, boardName, openBoardForm, createBoard, deleteBoard }
});
