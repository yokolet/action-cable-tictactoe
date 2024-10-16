# frozen_string_literal: true

class TicTacToeBoard
  attr_reader :name

  def initialize(name)
    @name = name
    @count = 0
    @state = :waiting  # :waiting, :ongoing, :finished, or :terminated
    @play_result = :go_next  # :go_next, :x_wins, :o_wins, :draw
    @board = [
      ['', '', ''],
      ['', '', ''],
      ['', '', '']
    ]
    @player_ids = {}
  end

  def snapshot
    return {
      name: @name,
      count: @count,
      state: @state,
      play_result: @play_result,
      board: @board,
      player_ids: @player_ids
    }
  end

  def player_type(player_id)
    return @player_ids[player_id]
  end

  def join(player_id)
    return {
      type: player_type(player_id),
      state: @state
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
      type: player_type(player_id),
      state: @state
    }
  end

  def player_x
    @player_ids.filter {|_, v| v == :playing_x}.keys[0]
  end

  def player_o
    @player_ids.filter {|_, v| v == :playing_o}.keys[0]
  end

  def update(x, y, id)
    # play_result: :go_next, :x_wins, :o_wins, :draw
    if @player_ids[id] == :viewing ||
      (@player_ids[id] == :playing_x && @count % 2 == 1) ||
      (@player_ids[id] == :playing_o && @count % 2 == 0) ||
      @board[x][y] != '' ||
      @state != :ongoing
      return {
        play_result: @play_result,
        state: @state,
        count: @count,
        board: @board
      }
    end
    @board[x][y] = @count % 2 == 0 ? 'x' : 'o'
    @count += 1

    if winner?
      @state = :finished
      @play_result = @count % 2 == 1 ? :x_wins : :o_wins
    elsif @count == 9
      @state = :finished
      @play_result = :draw
    end
    return {
      play_result: @play_result,
      state: @state,
      count: @count,
      board: @board
    }
  end

  def terminate
    @state = :terminated
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
