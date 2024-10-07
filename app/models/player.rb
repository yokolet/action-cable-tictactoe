# frozen_string_literal: true

class Player
  attr_reader :name, :board_id

  def initialize(name)
    @name = name
  end

  def creator_of(board_id)
    @board_id = board_id
  end
end
