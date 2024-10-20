class BoardChannel < ApplicationCable::Channel
  include CacheManager

  def subscribed
    # stream_from "some_channel"
    board_id = params[:board_id]
    result = { action: 'board:action:subscribed' }
    if board_id
      board = find(board_id)
      if board
        stream_from "board_channel_#{board_id}"
        board.join(current_player_id)
        board.update_name(player_name(current_player_id), current_player_id)
        maintenance(current_player_id, board_id, board)
        current_board = board.snapshot
        result[:status] = 'board:status:success'
        result[:message] = "Successfully subscribed to #{board.name}."
        result[:name] = board.name
        result[:bid] = board_id
        result[:x_name] = board.x_name
        result[:o_name] = board.o_name
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
    board_ids = find(current_player_id).player_of if find(current_player_id)
    board_ids.each { |board_id| find(board_id).terminate if find(board_id) }
  end

  def heads_up(data)
    result = { action: data['act'] || 'board:action:heads_up' }
    board = find(data['bid'])
    if board
      current_board = board.snapshot
      result[:status] = 'board:status:success'
      result[:message] = data['message']
      result[:bid] = data['bid']
      result[:x_name] = board.x_name
      result[:o_name] = board.o_name
      result[:play_result] = current_board[:play_result]
      result[:board_state] = current_board[:state]
      result[:board_count] = current_board[:count]
      result[:board_data] = current_board[:board]
    else
      result[:status] = 'board:status:retry'
      result[:message] = 'The board might be deleted. Choose another or create.'
    end
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
    replace_instance(data['bid'], board)
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

  private

  def player_name(pid)
    pid && find(pid) ? find(pid).name : ''
  end

  def maintenance(pid, bid, board)
    replace_instance(bid, board)
    player = find(pid)
    if player
      player.add(bid)
      replace_instance(pid, player)
    end
  end
end
