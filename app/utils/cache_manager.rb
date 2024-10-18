# frozen_string_literal: true

module CacheManager
  # Players
  # key: :players, value: {player_key: player_id}
  # Each player
  # key: player_id, value: Player instance

  # BoardList
  # key: baords, value: {board_key: board_id}
  # Each board
  # key: board_id, value: TicTacToeBoard instance

  def sanitize(name)
    # allows alphanumeric, single quote, underscore, hyphen, and only one space in between
    # limits length to 30
    name.squish.gsub(/[^A-Za-z0-9'\-_\s]/, '')[0...30].strip
  end

  def to_key(name)
    name.downcase.to_sym
  end

  def current_instances(key)
    instances = Rails.cache.fetch(key) { {} }.
      filter {|_, id| Rails.cache.read(id)}
    Rails.cache.write(key, instances)
    instances
  end

  def current_players
    current_instances(:players)
  end

  def current_boards
    current_instances(:boards)
  end

  def current_player_list
    current_players.values.
      map { |pid| Rails.cache.read(pid) }.
      map { |player| player.name }
  end

  def current_board_list
    current_boards.values.
      map { |bid| [bid, Rails.cache.read(bid)] }.
      map { |bid, board| [bid, board.name] }
  end

  def existing_player?(name)
    current_players.include?(to_key(sanitize(name)))
  end

  def existing_board?(name)
    current_boards.include?(to_key(sanitize(name)))
  end

  def add_new(name, id, type, clazz)
    name = sanitize(name)
    key = to_key(name)
    instances = current_instances(type)
    instances[key] = id
    Rails.cache.write(type, instances)
    Rails.cache.write(id, clazz.new(name))
  end

  def add_new_player(name, id)
    add_new(name, id, :players, Player)
  end

  def add_new_board(name, id)
    add_new(name, id, :boards, TicTacToeBoard)
  end

  def delete_instance(id, type)
    instance = Rails.cache.read(id)
    if instance
      key = to_key(sanitize(instance.name))
      instances = current_instances(type)
      instances.delete(key)
      Rails.cache.write(type, instances)
      Rails.cache.delete(id)
    end
  end

  def delete_player(pid)
    delete_instance(pid, :players)
  end

  def delete_board(bid)
    delete_instance(bid, :boards)
  end

  def clear_instances(key)
    instances = Rails.cache.fetch(key) { {} }
    instances.each_pair {|_, bid| Rails.cache.delete(bid)}
    Rails.cache.delete(key)
  end

  def clear_players
    clear_instances(:players)
  end

  def clear_boards
    clear_instances(:boards)
  end
end
