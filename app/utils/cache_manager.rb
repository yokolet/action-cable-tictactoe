# frozen_string_literal: true

module CacheManager
  # Players
  # key: :players, value: {player_name_key: player_id}
  # Each player
  # key: player_id, value: Player instance

  # BoardList
  # key: :boards, value: {board_name_key: board_id}
  # Each board
  # key: board_id, value: TicTacToeBoard instance

  MAX_NUMBER_OF_INSTANCES = 20

  def sanitize(name)
    # allows alphanumeric, single quote, underscore, hyphen, and only one space in between
    # limits length to 30
    name.squish.gsub(/[^A-Za-z0-9'\-_\s]/, '')[0...30].strip
  end

  def to_key(name)
    name.downcase.to_sym
  end

  # finds an instance by id
  # the instance may be player or board
  def find(id)
    Rails.cache.read(id)
  end

  # returns currently existing instances by a hash of {name_key1 => id1, name_key2 => id2}
  # the method maintains instances at the same time
  #     delete instances whose keep? method returns false
  #     delete name_key and id pair if the given id doesn't find an instance
  def current_instances(key)
    # possibly deletes expired instances
    Rails.cache.cleanup
    # possibly deletes boards which return false from keep? method
    # players will be deleted by delete_instance method, not here -- players' keep? always returns true
    to_be_deleted_name_key = []
    Rails.cache.fetch(key) { {} }.each_pair do |name_key, id|
      if !Rails.cache.read(id) || !Rails.cache.read(id).keep?
        to_be_deleted_name_key << name_key
        Rails.cache.delete(id)
      end
    end
    instances = Rails.cache.fetch(key) { {} }
    to_be_deleted_name_key.each { |name_key| instances.delete(name_key) }
    Rails.cache.write(key, instances)
    instances
  rescue => error
    raise
  end

  def current_players
    current_instances(:players)
  end

  def current_boards
    current_instances(:boards)
  end

  # uses to get a list of players
  def current_instance_list(key)
    current_instances(key).values.
      filter { |id| Rails.cache.read(id) }.
      map { |id| Rails.cache.read(id).name }
  end

  def current_player_list
    current_instance_list(:players)
  end

  # uses to get a list of [board_id, board_instance] pairs
  def current_instance_pair_list(key)
    current_instances(key).values.
      filter { |id| Rails.cache.read(id) }.
      map { |id| [id, Rails.cache.read(id).name] }
  end

  def current_board_list
    current_instance_pair_list(:boards)
  end

  def available_instance?(name, key)
    result = { status: true, reason: :ok }
    instances = current_instances(key)
    if instances.length == MAX_NUMBER_OF_INSTANCES
      result[:status] = false
      result[:reason] = :max_number
    elsif instances.include?(to_key(sanitize(name)))
      result[:status] = false
      result[:reason] = :duplicate
    end
    result
  end

  def available_player?(name)
    available_instance?(name,:players)
  end

  def available_board?(name)
    available_instance?(name, :boards)
  end

  def add_new(name, id, key, clazz)
    name = sanitize(name)
    instances = current_instances(key)
    instances[to_key(name)] = id
    Rails.cache.write(key, instances)
    Rails.cache.write(id, clazz.new(name), expires_in: 10.minutes)
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

  # deletes a player by player_channel's unsubscribe or unregister methods
  def delete_instance(id, key)
    # delete a name_key => id pair from the instance list
    to_be_deleted = Rails.cache.fetch(key) { {} }.filter { |_, pid| id == pid }
    instances = Rails.cache.fetch(key) { {} }
    instances.delete(to_be_deleted.keys[0])
    Rails.cache.write(key, instances)

    # delete an instance
    instance = Rails.cache.read(id)
    return if !instance
    # when a player is player_x or player_y, the ongoing board's status should be changed to :terminated
    if instance.respond_to?(:player_of)
      instance.player_of.each do |bid|
        board = find(bid)
        if board && (board.player_x == id || board.player_o == id)
          board.terminate
          Rails.cache.write(bid, board)
        end
      end
    end
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
