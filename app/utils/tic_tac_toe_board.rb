# frozen_string_literal: true

class TicTacToeBoard
  attr_reader :count, :state, :player_ids

  def initialize
    @count = 0
    @state = :waiting
    @board = [
      ['', '', ''],
      ['', '', ''],
      ['', '', '']
    ]
    @player_ids = {}
  end

  def join(player_id)
    case @player_ids.length
    when 0
      @player_ids[player_id] = :playing_x
    when 1
      @player_ids[player_id] = :playing_o
      @state = :ongoing
    else
      @player_ids[player_id] = :viewing
    end
    return @player_ids[player_id]
  end

  def update(x, y, id)
    if @player_ids[id] == :viewing
      return {
        status: :not_allowed,
        board: @board
      }
    elsif (@player_ids[id] == :playing_x && @count % 2 == 1) ||
      (@player_ids[id] == :playing_o && @count % 2 == 0) ||
      @board[x][y] != ''
      return {
        status: :invalid,
        board: @board
      }
    end
    @board[x][y] = @count % 2 == 0 ? 'x' : 'o'
    @count += 1

    if winner?
      @state = :finished
      return {
        status: @count % 2 == 1 ? :x_wins : :o_wins,
        board: @board
      }
    elsif @count == 9
      @state = :finished
      return {
        status: :draw,
        board: @board
      }
    else
      return {
        status: :ongoing,
        board: @board
      }
    end
  end

  private

  def winner?
    if @count >= 5
      return checkHorizontal || checkVertical || checkDiagonals
    else
      return false
    end
  end

  def checkCells(cells)
    cells.all? {|cell| cell == 'x'} || cells.all? {|cell| cell == 'o'}
  end

  def checkHorizontal
    @board.map { |row| checkCells(row) }.any?
  end

  def checkVertical
    transposed = [0, 1, 2].map {|c| @board.map {|r| r[c]}}
    transposed.map { |row| checkCells(row) }.any?
  end

  def checkDiagonals
    checkCells([@board[0][0], @board[1][1], @board[2][2]]) ||
      checkCells([@board[0][2], @board[1][1], @board[2][0]])
  end
end
