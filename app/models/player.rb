# frozen_string_literal: true

class Player
  attr_reader :name, :player_of

  def initialize(name)
    @name = name
    @player_of = Set.new
  end

  def add(bid)
    @player_of.add(bid)
  end

  def keep?
    true
  end
end
