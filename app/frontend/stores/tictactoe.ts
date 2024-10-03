import { ref, computed } from 'vue'
import { defineStore } from 'pinia'

export const useTicTacToeStore = defineStore('tic-tac-toe', () => {
  const player = ref<string>('X');
  const winner = ref<string | null>(null);
  const count = ref<number>(0);
  const board = ref<string[][]>(
    [
      ['', '', ''],
      ['', '', ''],
      ['', '', ''],
    ]
  );

  const resetBoard = () => {
    board.value =
      [
        ['', '', ''],
        ['', '', ''],
        ['', '', ''],
      ];
    player.value = 'X';
    winner.value = null;
    count.value = 0;
  };

  const updateBoard = (x: number, y: number) => {
    if (board.value[x][y] !== '' || winner.value !== null) return;
    board.value[x][y] = player.value;
    player.value = player.value === 'X' ? 'O' : 'X';
    count.value++;
    if (count.value >= 5) {
      winner.value = checkHorizontal() || checkVertical() || checkMainDiagonal() || checkSecondaryDiagonal();
    }
  };

  const checkCells = (cells: string[]): boolean => cells.every((c) => c === cells[0]);

  const checkHorizontal = (): string | null => {
    for (let i = 0; i < 3; ++i) {
      if (checkCells(board.value[i])) {
        return board.value[i][0];
      }
    }
    return null;
  };

  const checkVertical = (): string | null => {
    for (let i = 0; i < 3; ++i) {
      const cells: string[] = [];
      cells.push(board.value[0][i]);
      cells.push(board.value[1][i]);
      cells.push(board.value[2][i]);
      if (checkCells(cells)) {
        return cells[0];
      }
    }
    return null;
  };

  const checkMainDiagonal = (): string | null => {
    const cells: string[] = [];
    cells.push(board.value[0][0]);
    cells.push(board.value[1][1]);
    cells.push(board.value[2][2]);
    if (checkCells(cells)) {
      return cells[0];
    }
    return null;
  }

  const checkSecondaryDiagonal = (): string | null => {
    const cells: string[] = [];
    cells.push(board.value[0][2]);
    cells.push(board.value[1][1]);
    cells.push(board.value[2][0]);
    if (checkCells(cells)) {
      return cells[0];
    }
    return null;
  }

  const isTie = computed(() => count.value == 9 && winner.value === null);
  const isOver = computed(() => winner.value !== null || isTie.value);

  return { player, board, winner, isTie, isOver, updateBoard, resetBoard  }
});
