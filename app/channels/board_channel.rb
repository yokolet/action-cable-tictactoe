class BoardChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    board_id = params[:board_id]
    result = { action: 'board:action:subscribed' }
    if board_id
      board = find(board_id)
      if board
        stream_from "board_channel_#{board_id}"
        board_status = board.join(current_player_id)
        replace(board_id, board)
        result[:status] = 'board:status:success'
        result[:message] = "Successfully subscribed to #{board.name}"
        result[:name] = board.name
        result[:bid] = board_id
        result[:player_x] = player_x(board)
        result[:player_o] = player_o(board)
        result[:board_state] = board_status[:state]
        result[:board_count] = board.count
        result[:board_data] = board_status[:board]
      else
        result[:status] = 'board:status:retry'
        result[:message] = 'The board might be deleted. Choose another or create.'
      end
    end
  rescue => error
    result[:status] = "error"
    result[:message] = error.message
  ensure
    transmit(result)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    board_id = params[:board_id]
    if board_id
      stop_stream_from "board_channel_#{board_id}"
    end
  end

  def leave_board(data)
    puts("leave_board: player_id: #{current_player_id}, board: #{data["bid"]}")
    result = { action: 'board:action:leave' }
    board = find(data['bid'])
    if board
      stop_stream_from "board_channel_#{data['bid']}"
      result[:status] = 'board:status:success'
      result[:message] = "Successfully left the board: #{board.name}"
    end
  rescue => error
    result[:status] = 'board:status:error'
    result[:message] = error.message
  ensure
    transmit(result)
  end

  def heads_up(data)
    board = find(data['bid'])
    result = {
      action: 'board:action:heads_up',
      status: 'board:status:success',
      message: data['message'],
      bid: data['bid'],
      player_type: board.player_ids[current_player_id],
      player_name: player_name(current_player_id),
      board_state: board.state
    }
    puts("BoardChannel: heads up: input data = #{data.inspect}")
    puts("BoardChannel: heads up: result = #{result.inspect}")
    puts("BoardChannel: heads up: board = #{board.inspect}, player: #{current_player_id}")
    ActionCable.server.broadcast("board_channel_#{data["bid"]}", result)
  rescue => error
    result[:status] = 'board:status:error'
    result[:message] = error.message
    transmit(result)
  end

  def play(data)
    result = { action: 'board:action:play' }
    board = find(data['bid'])
    board_status = board.update(data['x'], data['y'], current_player_id)
    replace(data['bid'], board)
    if [:go_next, :x_wins, :o_wins, :draw].include?(board_status[:play_result])
      result[:status] = 'board:status:success'
      result[:bid] = data['bid']
      result[:play_result] = board_status[:play_result]
      result[:board_count] = board_status[:count]
      result[:board_data] = board_status[:board]
      ActionCable.server.broadcast("board_channel_#{data['bid']}", result)
    end
  rescue => error
    result[:status] = 'board:status:error'
    result[:message] = error.message
    transmit(result)
  end

  private

  def find(board_id)
    Rails.cache.read(board_id)
  end

  def replace(board_id, board)
    Rails.cache.write(board_id, board)
  end

  def player_name(player_id)
    Rails.cache.read(player_id).name
  end

  def player_x(board)
    pid = board.player_ids.filter {|_, v| v == :playing_x}.keys[0]
    pid ? player_name(pid) : ''
  end

  def player_o(board)
    pid = board.player_ids.filter {|_, v| v == :playing_o}.keys[0]
    pid ? player_name(pid) : ''
  end
end
