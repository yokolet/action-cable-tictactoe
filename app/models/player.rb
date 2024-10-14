# frozen_string_literal: true

class Player
  attr_reader :name, :player_of

  def initialize(name)
    @name = name
    @player_of = []
  end

  def join(board_id)
    @player_of << board_id
  end
end
