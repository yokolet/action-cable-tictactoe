class PlayerChannel < ApplicationCable::Channel
  include CacheManager

  def subscribed
    player_name = params[:player]
    stream_from "player_channel"
    result = {
      action: 'player:action:subscribed',
      status: available_player?(player_name)[:status] ? 'player:status:non-existing' : 'player:status:existing',
      players: current_player_list,
      #players: static_player_names, # for ui testing purpose
    }
  rescue => error
    result[:status] = 'player:status:error'
    result[:message] = error.message
  ensure
    transmit(result)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    delete_player(current_player_id)
    result = {
      action: 'player:action:unsubscribed',
      status: 'player:status:success',
      players: current_player_list,
    }
    ActionCable.server.broadcast("player_channel", result)
  end

  def register(data)
    messages = {
      max_number: "A number of players reached to maximum. Try later",
      duplicate: "The player name #{sanitize(data["player"])} exists. Choose another.",
      ok: "#{sanitize(data["player"])} has been registered."
    }
    result = { action: 'player:action:register' }
    player_name = sanitize(data["player"])
    availability = available_player?(player_name)
    if (!availability[:status])
      result[:status] = 'player:status:retry'
      result[:message] = messages[availability[:reason]]
    else
      add_new_player(player_name, current_player_id)
      result[:status] = 'player:status:success'
      result[:message] = "#{player_name} has been registered successfully."
    end
  rescue => error
    result[:status] = 'player:status:error'
    result[:message] = error.message
  ensure
    transmit(result)
  end

  def unregister(_)
    result = { action: 'player:action:unregister' }
    delete_player(current_player_id)
    result[:status] = 'player:status:success'
    result[:players] = current_player_list
  rescue => error
    result[:status] = 'player:status:error'
    result[:message] = error.message
  ensure
    transmit(result)
  end

  def heads_up(data)
    result = {
      action: data['act'] || 'player:action:heads_up',
      status: 'player:status:success',
      players: current_player_list,
      message: data['message']
    }
    ActionCable.server.broadcast("player_channel", result)
  end

  private

  def static_player_names
    [
      'Bob', 'Christopher', "D'Arcy", 'Ellen', 'Francisca', 'Guadalupe', 'Hayden',
    ]
  end
end
