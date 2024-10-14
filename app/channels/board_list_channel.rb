class BoardListChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from "board_list_channel"
    result = {
      action: "board-list:action:subscribed",
      status: "board-list:status:success",
      boards: current_board_list,
      #boards: static_board_list, # for ui testing purpose
    }
  rescue => error
    result[:status] = "board-list:status:error"
    result[:message] = error.message
  ensure
    transmit(result)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def create_board(data)
    puts("creator_id: #{current_player_id}, board_id: #{data["board_id"]}, board_name: #{data["board_name"]}")
    result = add_board(data["board_id"], data["board_name"])
  rescue => error
    result[:status] = "board-list:status:error"
    result[:message] = error.message
  ensure
    transmit(result)
  end

  def delete_board(data)
    delete_board(data['board_id'])
  end

  def heads_up(data)
    result = {
      action: 'board-list:action:heads_up',
      status: 'board-list:status:success',
      boards: current_board_list,
      message: data['message']
    }
    puts("board-list:action:heads_up: result = #{result.inspect}")
    ActionCable.server.broadcast("board_list_channel", result)
  end

  private

  def static_board_list # for ui debug
    [
      ['ab-12', 'Mario Kart 8'],
      ['cd-34', 'Pokémon Omega Ruby'],
      ['ef-56', 'Batman: Arkham Asylum'],
      ['gh-78', 'BioShock']
    ]
  end

  def board_key(board_name)
    board_name.downcase.to_sym
  end

  def current_boards
    boards = Rails.cache.fetch(:boards) { {} }
    boards = boards.filter {|_, bid| Rails.cache.read(bid)}    # remove expired board
    Rails.cache.write(:boards, boards)
    boards
  end

  def current_board_list
    current_boards.values.
      map { |board_id| [board_id, Rails.cache.read(board_id)] }.
      filter {|board_pair| board_pair.last }.
      map { |board_pair| [board_pair[0], board_pair[1].snapshot[:name]] }
  end

  def existing_board?(board_key)
    current_boards.include?(board_key)
  end

  def add_board(board_id, board_name)
    result = { action: "board-list:action:create" }
    key = board_key(board_name)
    puts("board_id: #{board_id}, board_name: #{board_name}, key: #{key}")
    if (existing_board?(key))
      result[:status] = "board-list:status:retry"
      result[:message] = "The board name #{board_name} exists. Choose another."
    else
      boards = current_boards
      boards[key] = board_id
      Rails.cache.write(board_id, TicTacToeBoard.new(board_name), expires_in: 1.hour)
      Rails.cache.write(:boards, boards)
      result[:status] = "board-list:status:success"
      result[:message] = "#{board_name} has been created successfully."
      result[:bid] = board_id
    end
  rescue => error
    result[:status] = "board-list:status:error"
    result[:message] = error.message
  ensure
    return result
  end

  def delete_board(board_id)
    board = Rails.cache.read(board_id)
    if board
      boards = current_boards
      boards.delete(board_key(board.name))
      Rails.cache.write(:boards, boards)
      Rails.cache.delete(board_id)
    end
  end
end
