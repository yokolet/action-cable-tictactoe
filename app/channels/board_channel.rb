class BoardChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    board_id = params[:board_id]
    result = { action: 'board:action:subscribed' }
    if board_id
      board = find(board_id)
      puts("BoardChannel subscribed, board_id: board  #{board_id}: #{board.inspect}")
      if board
        stream_from "board_channel_#{board_id}"
        board.join(current_player_id)
        replace(board_id, board)
        current_board = board.snapshot
        result[:status] = 'board:status:success'
        result[:message] = "Successfully subscribed to #{current_board[:name]}"
        result[:name] = current_board[:name]
        result[:bid] = board_id
        result[:x_name] = player_name(board.player_x)
        result[:o_name] = player_name(board.player_o)
        result[:play_result] = current_board[:play_result]
        result[:board_state] = current_board[:state]
        result[:board_count] = current_board[:count]
        result[:board_data] = current_board[:board]
      else
        result[:status] = 'board:status:retry'
        result[:message] = 'The board might be deleted. Choose another or create.'
      end
    end
  rescue => error
    result[:status] = "board:status:error"
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

  def heads_up(data)
    board = find(data['bid'])
    current_board = board.snapshot
    result = {
      action: 'board:action:heads_up',
      status: 'board:status:success',
      message: data['message'],
      bid: data['bid'],
      player_type: board.player_type(current_player_id),
      player_name: player_name(current_player_id),
      board_state: current_board[:state]
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
      result[:board_state] = board_status[:state]
      result[:board_count] = board_status[:count]
      result[:board_data] = board_status[:board]
      ActionCable.server.broadcast("board_channel_#{data['bid']}", result)
    end
  rescue => error
    result[:status] = 'board:status:error'
    result[:message] = error.message
    transmit(result)
  end

  def leave(_)
    terminated_boards(current_player_id).each do |bid|
      result = {
        action: 'board:action:leave',
        status: 'board:status:success',
        bid: bid,
        board_state: :terminated
      }
      ActionCable.server.broadcast("board_channel_#{bid}", result)
    end

  end

  private

  def find(board_id)
    Rails.cache.read(board_id)
  end

  def replace(board_id, board)
    Rails.cache.write(board_id, board)
  end

  def player_name(player_id)
    player_id && Rails.cache.read(player_id) ? Rails.cache.read(player_id).name : ''
  end

  def terminated_boards(player_id)
    board_list = Rails.cache.read(:boards)
    return [] if !board_list
    result = []
    board_list.values.each do |bid|
      board = Rails.cache.read(bid)
      next if !board
      current_board = board.snapshot
      if current_board[:state] == :ongoing && (board.player_x == player_id || board.player_o == player_id)
        board.terminate
        result << bid
      end
    end
    result
  end
end
