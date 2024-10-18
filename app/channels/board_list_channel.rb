class BoardListChannel < ApplicationCable::Channel
  include CacheManager

  def subscribed
    stream_from 'board_list_channel'
    result = {
      action: 'board-list:action:subscribed',
      status: 'board-list:status:success',
      boards: current_board_list,
      #boards: static_board_list, # for ui testing purpose
    }
  rescue => error
    result[:status] = 'board-list:status:error'
    result[:message] = error.message
  ensure
    transmit(result)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def create_board(data)
    result = { action: 'board-list:action:create' }
    if (existing_board?(data["board_name"]))
      result[:status] = 'board-list:status:retry'
      result[:message] = "The board name #{sanitize(data["board_name"])} exists. Choose another."
    else
      add_new_board(data["board_name"], data["board_id"])
      result[:status] = 'board-list:status:success'
      result[:message] = "#{sanitize(data["board_name"])} has been created."
      result[:bid] = data["board_id"]
    end
  rescue => error
    result[:status] = 'board-list:status:error'
    result[:message] = error.message
  ensure
    transmit(result)
  end

  def delete_board(_)
    # Deleting a board from a board list doesn't happen by action.
    # The board is just expired.
    # When the current_boards method gets called, the expired board is removed from the list.
  end

  def heads_up(data)
    result = {
      action: data['act'] || 'board-list:action:heads_up',
      status: 'board-list:status:success',
      message: data['message']
    }
    result[:boards] = current_board_list
    ActionCable.server.broadcast('board_list_channel', result)
  rescue => error
    result[:status] = 'board-list:status:error'
    result[:message] = error.message
    transmit(result)
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
end
