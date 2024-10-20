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

  def find(id)
    Rails.cache.read(id)
  end

  def current_instances(key)
    # possibly deletes boards who return false from keep? method
    instances = Rails.cache.fetch(key) { {} }
    instances.
      filter { |_, id| Rails.cache.read(id) && !Rails.cache.read(id).keep? }.
      each_pair { |_, id| delete_instance(id, key) }
    # possibly deletes players/boards who are expired
    instances = Rails.cache.fetch(key) { {} }
    to_be_deleted = instances.filter { |_, id| !Rails.cache.read(id) }.map { |name, _| name }
    to_be_deleted.each { |name| instances.delete(name) }
    Rails.cache.write(key, instances)
    instances
  end

  def current_players
    current_instances(:players)
  end

  def current_boards
    current_instances(:boards)
  end

  def current_instance_list(key)
    current_instances(key).values.
      map { |id| Rails.cache.read(id) }.
      map { |instance| instance.name }
  end

  def current_player_list
    current_instance_list(:players)
  end

  def current_instance_pair_list(key)
    current_instances(key).values.
      map { |id| [id, Rails.cache.read(id)] }.
      map { |id, instance| [id, instance.name] }
  end

  def current_board_list
    current_instance_pair_list(:boards)
  end

  def existing_instance?(name, key)
    current_instances(key).include?(to_key(sanitize(name)))
  end

  def existing_player?(name)
    existing_instance?(name,:players)
  end

  def existing_board?(name)
    existing_instance?(name, :boards)
  end

  def add_new(name, id, key, clazz)
    name = sanitize(name)
    instances = current_instances(key)
    instances[to_key(name)] = id
    Rails.cache.write(key, instances)
    Rails.cache.write(id, clazz.new(name), expires: 15.minutes)
  end

  def add_new_player(name, id)
    add_new(name, id, :players, Player)
  end

  def add_new_board(name, id)
    add_new(name, id, :boards, TicTacToeBoard)
  end

  def replace_instance(id, instance)
    Rails.cache.write(id, instance)
  end

  def delete_instance(id, key)
    instance = Rails.cache.read(id)
    return if !instance
    if instance.respond_to?(:player_of)
      instance.player_of.each do |bid|
        board = find(bid)
        board.terminate if board
      end
    end
    instances = current_instances(key)
    instances.delete(to_key(sanitize(instance.name)))
    Rails.cache.write(key, instances)
    Rails.cache.delete(id)
  end

  def delete_player(pid)
    delete_instance(pid, :players)
  end

  def delete_board(bid)
    delete_instance(bid, :boards)
  end

  def clear_instances(key)
    instances = Rails.cache.fetch(key) { {} }
    instances.each_pair {|_, id| Rails.cache.delete(id)}
    Rails.cache.delete(key)
  end

  def clear_players
    clear_instances(:players)
  end

  def clear_boards
    clear_instances(:boards)
  end
end
