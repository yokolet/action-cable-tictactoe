class BoardChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    board_id = params[:board_id]
    result = { action: 'board:action:subscribed' }
    if board_id
      board = find(board_id)
      if board
        stream_from "board_channel_#{board_id}"
        result[:status] = 'board:status:success'
        result[:name] = board.name
        result[:bid] = board_id
        result[:message] = "Successfully subscribed to #{board.name}"
        result[:board] = []
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
    puts("leave_board: player_id: #{current_player_id}, board: #{data["boardId"]}")
    result = { action: 'board:action:leave' }
    board = find(data["boardId"])
    if board
      stop_stream_from "board_channel_#{data["boardId"]}"
      result[:status] = 'board:status:success'
      result[:message] = "Successfully left the board: #{board.name}"
    end
  rescue => error
    result[:status] = 'board:status:error'
    result[:message] = error.message
  ensure
    transmit(result)
  end

  def play(data)

  end

  private

  def find(board_id)
    Rails.cache.read(board_id)
  end
end
