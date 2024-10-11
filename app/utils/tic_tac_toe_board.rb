# frozen_string_literal: true

class TicTacToeBoard
  attr_reader :name, :count, :state, :player_ids

  def initialize(name)
    @name = name
    @count = 0
    @state = :waiting  # :waiting, :ongoing, :finished
    @board = [
      ['', '', ''],
      ['', '', ''],
      ['', '', '']
    ]
    @player_ids = {}
  end

  def join(player_id)
    return {
      type: @player_ids[player_id],
      state: @state,
      board: @board
    } if @player_ids.has_key?(player_id)

    case @player_ids.length
    when 0
      @player_ids[player_id] = :playing_x
      @state = :waiting
    when 1
      @player_ids[player_id] = :playing_o
      @state = :ongoing
    else
      @player_ids[player_id] = :viewing
    end
    return {
      type: @player_ids[player_id],
      state: @state,
      board: @board
    }
  end

  def update(x, y, id)
    # play_result: :go_next, :x_wins, :o_wins, :draw, :invalid, :not_allowed
    if @player_ids[id] == :viewing
      return {
        play_result: :not_allowed,
        count: @count,
        board: @board
      }
    elsif (@player_ids[id] == :playing_x && @count % 2 == 1) ||
      (@player_ids[id] == :playing_o && @count % 2 == 0) ||
      @board[x][y] != ''
      return {
        play_result: :invalid,
        count: @count,
        board: @board
      }
    end
    @board[x][y] = @count % 2 == 0 ? 'x' : 'o'
    @count += 1

    if winner?
      @state = :finished
      return {
        play_result: @count % 2 == 1 ? :x_wins : :o_wins,
        count: @count,
        board: @board
      }
    elsif @count == 9
      @state = :finished
      return {
        play_result: :draw,
        count: @count,
        board: @board
      }
    else
      return {
        play_result: :go_next,
        count: @count,
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
