# frozen_string_literal: true

class TicTacToeBoard
  attr_reader :name, :x_name, :o_name, :last_updated

  def initialize(name)
    @name = name
    @x_name = nil
    @o_name = nil
    @count = 0
    @state = :waiting  # :waiting, :ongoing, :finished, or :terminated
    @play_result = :go_next  # :go_next, :x_wins, :o_wins, :draw
    @board = [
      ['', '', ''],
      ['', '', ''],
      ['', '', '']
    ]
    @player_ids = {}
    @last_updated = Time.now
  end

  def snapshot
    return {
      count: @count,
      state: @state,
      play_result: @play_result,
      board: @board
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
      @last_updated = Time.now
    when 1
      @player_ids[player_id] = :playing_o
      @state = :ongoing
      @last_updated = Time.now
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

  def update_name(name, id)
    case @player_ids[id]
    when :playing_x
      @x_name ||= name
    when :playing_o
      @o_name ||= name
    else
      # do nothing
    end
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

    @last_updated = Time.now
    return {
      play_result: @play_result,
      state: @state,
      count: @count,
      board: @board
    }
  end

  def terminate
    @state = :terminated if @state != :finished
  end

  def keep?
    return false if (@state == :terminated || @state == :finished) && (@last_updated + 3.minute) < Time.now
    return false if (@state == :waiting || @state == :ongoing) && (@last_updated + 5.minute) < Time.now
    true
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
