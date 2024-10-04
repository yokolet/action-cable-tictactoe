class PlayerChannel < ApplicationCable::Channel
  def subscribed
    stream_from "player_channel"
    transmit({ players: current_player_names })
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    delete_player(current_player_id)
    transmit({ players: current_player_names })
  end

  def register(data)
    result = add_player(current_player_id, data[:name])
    if result[:status] == "success"
      ActionCable.server.broadcast("player_channel", { players: current_player_names })
    else
      transmit(result)
    end
  end

  def unregister(_)
    delete_player(current_player_id)
    ActionCable.server.broadcast("player_channel", { players: current_player_names })
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

  def existing_player?(player_key)
    current_players.include?(player_key)
  end

  def add_player(player_id, player_name)
    result = { name: player_name }
    key = player_key(player_name)
    if (existing_player?(key))
      result[:status] = "retry"
      result[:message] = "Player name #{player_name} exists. Choose another."
    else
      players = current_players
      players[key] = player_id
      Rails.cache.write(player_id, Player.new(player_name), expires_in: 1.hour)
      Rails.cache.write(:players, players)
      result[:status] = "success"
      result[:message] = "You are registered as #{player_name}. Start playing a game."
    end
    result[:players] = current_players
    result
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
