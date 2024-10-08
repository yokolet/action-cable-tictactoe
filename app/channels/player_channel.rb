class PlayerChannel < ApplicationCable::Channel
  def subscribed
    player_name = params[:player]
    stream_from "player_channel"
    result = {
      action: "player:action:subscribed",
      status: existing_player?(player_key(player_name)) ? "player:status:existing" : "player:status:non-existing",
      players: current_player_names,
      #players: static_player_names, # for ui testing purpose
    }
  rescue => error
    result[:status] = "player:status:error"
    result[:message] = error.message
  ensure
    transmit(result)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    delete_player(current_player_id)
    result = {
      action: 'player:action:unsubscribed',
      status: 'success',
      players: current_player_names,
    }
    ActionCable.server.broadcast("player_channel", result)
  end

  def register(data)
    puts("player_id: #{current_player_id}, player: #{data["player"]}")
    result = add_player(current_player_id, data["player"])
  rescue => error
    result[:status] = "player:status:error"
    result[:message] = error.message
  ensure
    transmit(result)
  end

  def unregister(_)
    delete_player(current_player_id)
    result = {
      action: "player:action:unregister",
      status: "player:status:success",
      players: current_player_names,
    }
  rescue => error
    result[:status] = "player:status:error"
    result[:message] = error.message
  ensure
    transmit(result)
  end

  def heads_up(data)
    result = {
      action: data['action'],
      status: 'player:status:success',
      players: current_player_names,
      message: data['message']
    }
    puts("heads up: result = #{result.inspect}")
    ActionCable.server.broadcast("player_channel", result)
  end

  private

  def player_key(player_name)
    player_name.downcase.to_sym
  end

  def current_players
    Rails.cache.fetch(:players) { {} }
  end

  def current_player_names
    current_players.values.
      map { |player_id| Rails.cache.read(player_id) }.
      filter {|player| player }.
      map { |player| player.name }
  end

  def static_player_names
    [
      'Bob', 'Christopher', "D'Arcy", 'Ellen', 'Francisca', 'Guadalupe', 'Hayden',
    ]
  end

  def existing_player?(player_key)
    current_players.include?(player_key)
  end

  def add_player(player_id, player_name)
    result = { action: "player:action:register" }
    key = player_key(player_name)
    puts("player_id: #{player_id}, player_name: #{player_name}, key: #{key}")
    if (existing_player?(key))
      result[:status] = "player:status:retry"
      result[:message] = "Player name #{player_name} exists. Choose another."
    else
      players = current_players
      players[key] = player_id
      Rails.cache.write(player_id, Player.new(player_name), expires_in: 1.hour)
      Rails.cache.write(:players, players)
      result[:status] = "player:status:success"
      result[:message] = "#{player_name} has been registered successfully."
    end
  rescue => error
    result[:status] = "player:status:error"
    result[:message] = error.message
  ensure
    return result
  end

  def delete_player(player_id)
    player = Rails.cache.read(player_id)
    if player
      players = current_players
      players.delete(player_key(player.name))
      Rails.cache.write(:players, players)
      Rails.cache.delete(player_id)
    end
  end
end
