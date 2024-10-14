require 'rails_helper'

RSpec.describe "TicTacToeBoard", type: :util do
  describe "has been just created" do
    let!(:board) { TicTacToeBoard.new('My Board') }
    let(:player_ids) { 5.times.map {|_| SecureRandom.uuid } }

    it "has initial states" do
      result = board.snapshot
      expect(result[:name]).to eq('My Board')
      expect(result[:count]).to eq(0)
      expect(result[:state]).to eq(:waiting)
      expect(result[:play_result]).to eq(:go_next)
      expect(result[:board]).to eq([
                                     ['', '', ''],
                                     ['', '', ''],
                                     ['', '', ''],
                                   ])
      expect(result[:player_ids].length).to eq(0)
    end

    it "allows to join and returns a player status" do
      joined = player_ids.map { |id| board.join(id) }
      result = joined.map { |status| status[:type] }
      expect(result).to eq([:playing_x, :playing_o, :viewing, :viewing, :viewing])
      result = joined.map { |status| status[:state] }
      expect(result).to eq([:waiting, :ongoing, :ongoing, :ongoing, :ongoing])
    end

    it "doesn't allow the same player to join multiple times" do
      board.join(player_ids[0])
      board.join(player_ids[0])
      result = board.join(player_ids[0])
      expect(result[:type]).to eq(:playing_x)
      expect(result[:state]).to eq(:waiting)
    end
  end

  describe "after players are joined" do
    let(:player_ids) { 3.times.map {|_| SecureRandom.uuid } }

    before(:each) do
      @board = TicTacToeBoard.new('My Board')
      player_ids.map { |id| @board.join(id) }
    end

    it "returns initial state with updated player_ids" do
      result = @board.snapshot
      expect(result[:name]).to eq('My Board')
      expect(result[:count]).to eq(0)
      expect(result[:state]).to eq(:ongoing)
      expect(result[:play_result]).to eq(:go_next)
      expect(result[:board]).to eq([
                                     ['', '', ''],
                                     ['', '', ''],
                                     ['', '', ''],
                                   ])
      expect(result[:player_ids].length).to eq(3)
    end

    it "allows the first player to update firstly" do
      result = @board.update(0, 0, player_ids[0])
      expect(result[:play_result]).to eq(:go_next)
      expect(result[:state]).to eq(:ongoing)
      expect(result[:count]).to eq(1)
      expect(result[:board]).to eq([
                                     ['x', '', ''],
                                     ['', '', ''],
                                     ['', '', ''],
                                   ])
    end

    it "doesn't allow the second player to update firstly" do
      result = @board.update(0, 0, player_ids[1])
      expect(result[:play_result]).to eq(:go_next)
      expect(result[:state]).to eq(:ongoing)
      expect(result[:count]).to eq(0)
      expect(result[:board]).to eq([
                                     ['', '', ''],
                                     ['', '', ''],
                                     ['', '', ''],
                                   ])
    end

    it "doesn't allow the third player to update firstly" do
      result = @board.update(0, 0, player_ids[2])
      expect(result[:play_result]).to eq(:go_next)
      expect(result[:state]).to eq(:ongoing)
      expect(result[:count]).to eq(0)
      expect(result[:board]).to eq([
                                     ['', '', ''],
                                     ['', '', ''],
                                     ['', '', ''],
                                   ])
    end

    it "returns player x's id" do
      result = @board.player_x
      expect(result).to eq(player_ids[0])
    end

    it "returns player o's id" do
      result = @board.player_o
      expect(result).to eq(player_ids[1])
    end
  end

  describe "after players are joined and played once" do
    let(:player_ids) { 3.times.map {|_| SecureRandom.uuid } }

    before(:each) do
      @board = TicTacToeBoard.new('My Board')
      player_ids.map { |id| @board.join(id) }
      @board.update(0, 0, player_ids[0])
    end

    it "returns count 1 after one update" do
      result = @board.snapshot
      expect(result[:play_result]).to eq(:go_next)
      expect(result[:state]).to eq(:ongoing)
      expect(result[:count]).to eq(1)
      expect(result[:board]).to eq([
                                     ['x', '', ''],
                                     ['', '', ''],
                                     ['', '', ''],
                                   ])
    end

    it "doesn't allow the first player to update secondly" do
      result = @board.update(0, 1, player_ids[0])
      expect(result[:play_result]).to eq(:go_next)
      expect(result[:state]).to eq(:ongoing)
      expect(result[:count]).to eq(1)
      expect(result[:board]).to eq([
                                     ['x', '', ''],
                                     ['', '', ''],
                                     ['', '', ''],
                                   ])
    end

    it "allows the second player to update secondly" do
      result = @board.update(0, 1, player_ids[1])
      expect(result[:play_result]).to eq(:go_next)
      expect(result[:state]).to eq(:ongoing)
      expect(result[:count]).to eq(2)
      expect(result[:board]).to eq([
                                     ['x', 'o', ''],
                                     ['', '', ''],
                                     ['', '', ''],
                                   ])
    end

    it "doesn't allow a player to update the already marked cell" do
      result = @board.update(0, 0, player_ids[1])
      expect(result[:play_result]).to eq(:go_next)
      expect(result[:state]).to eq(:ongoing)
      expect(result[:count]).to eq(1)
      expect(result[:board]).to eq([
                                     ['x', '', ''],
                                     ['', '', ''],
                                     ['', '', ''],
                                   ])
    end

    it "doesn't allow the third player to update secondly" do
      result = @board.update(0, 1, player_ids[2])
      expect(result[:play_result]).to eq(:go_next)
      expect(result[:state]).to eq(:ongoing)
      expect(result[:count]).to eq(1)
      expect(result[:board]).to eq([
                                     ['x', '', ''],
                                     ['', '', ''],
                                     ['', '', ''],
                                   ])
    end
  end

  describe "has been ready to play" do
    let(:player_ids) { [SecureRandom.uuid, SecureRandom.uuid] }
    before(:each) do
      @board = TicTacToeBoard.new('My Board')
      @board.join(player_ids[0])
      @board.join(player_ids[1])
    end

    it "updates count and board with the game status :go_next" do
      count = 0
      [[0, 0], [0, 1], [0, 2]].each_with_index do |pos, idx|
        @board.update(pos[0], pos[1], player_ids[idx % 2])
        count += 1
      end
      result = @board.update(1, 0, player_ids[count % 2])
      expect(result[:play_result]).to eq(:go_next)
      expect(result[:state]).to eq(:ongoing)
      expect(result[:count]).to eq(4)
      expect(result[:board]).to eq([
                                     ['x', 'o', 'x'],
                                     ['o', '', ''],
                                     ['', '', ''],
                                   ])
    end

    it "doesn't allow to put the mark in a non-empty cell" do
      count = 0
      [[0, 0], [0, 1], [0, 2]].each_with_index do |pos, idx|
        @board.update(pos[0], pos[1], player_ids[idx % 2])
        count += 1
      end
      result = @board.update(0, 0, player_ids[count % 2])
      expect(result[:play_result]).to eq(:go_next)
      expect(result[:state]).to eq(:ongoing)
      expect(result[:count]).to eq(3)
      expect(result[:board]).to eq([
                                     ['x', 'o', 'x'],
                                     ['', '', ''],
                                     ['', '', ''],
                                   ])
    end

    it "returns the game status :x_wins" do
      count = 0
      [[0, 0], [1, 0], [0, 1], [1, 1]].each_with_index do |pos, idx|
        @board.update(pos[0], pos[1], player_ids[idx % 2])
        count += 1
      end
      result = @board.update(0, 2, player_ids[count % 2])
      expect(result[:play_result]).to eq(:x_wins)
      expect(result[:state]).to eq(:finished)
      expect(result[:count]).to eq(5)
      expect(result[:board]).to eq([
                                     ['x', 'x', 'x'],
                                     ['o', 'o', ''],
                                     ['', '', ''],
                                   ])
    end

    it "returns the game status :o_wins" do
      count = 0
      [[0, 0], [1, 0], [0, 1], [1, 1], [2, 2]].each_with_index do |pos, idx|
        @board.update(pos[0], pos[1], player_ids[idx % 2])
        count += 1
      end
      result = @board.update(1, 2, player_ids[count % 2])
      expect(result[:play_result]).to eq(:o_wins)
      expect(result[:state]).to eq(:finished)
      expect(result[:count]).to eq(6)
      expect(result[:board]).to eq([
                                     ['x', 'x', ''],
                                     ['o', 'o', 'o'],
                                     ['', '', 'x'],
                                   ])
    end

    it "returns the game status :draw" do
      count = 0
      [[0, 0], [0, 1], [0, 2], [1, 2], [1, 0], [2, 0], [1, 1], [2, 2]].each_with_index do |pos, idx|
        @board.update(pos[0], pos[1], player_ids[idx % 2])
        count += 1
      end
      result = @board.update(2, 1, player_ids[count % 2])
      expect(result[:play_result]).to eq(:draw)
      expect(result[:state]).to eq(:finished)
      expect(result[:count]).to eq(9)
      expect(result[:board]).to eq([
                                     ['x', 'o', 'x'],
                                     ['x', 'x', 'o'],
                                     ['o', 'x', 'o'],
                                   ])
    end

    it "doesn't allow to keep playing after x or o wins" do
      count = 0
      [[0, 0], [1, 0], [0, 1], [1, 1], [0, 2]].each_with_index do |pos, idx|
        @board.update(pos[0], pos[1], player_ids[idx % 2])
        count += 1
      end
      result = @board.update(1, 2, player_ids[count % 2])
      expect(result[:play_result]).to eq(:x_wins)
      expect(result[:state]).to eq(:finished)
      expect(result[:count]).to eq(5)
      expect(result[:board]).to eq([
                                     ['x', 'x', 'x'],
                                     ['o', 'o', ''],
                                     ['', '', ''],
                                   ])
    end
  end
end


# board can have only two players

# what about the first two players have a right to put x or o?
# when one of first two players left, the third will get a right to play?

# players can be add one by one
# the third and later people will be a viewer
#     what about leaving the board before the game ends?

# board has three states: waiting, ongoing, finished
# the result has four types: none, x-wins, o-wins, draw

# board updates the state by x, y coordinate
# board judges every time the state is updated to find a winner

# after thee board has the status of finished, the board will be deleted within 30 seconds or so

# example by EventMachine
# require 'eventmachine'
#
# class MyTimer
#   def initialize
#     @timer = EventMachine.add_timer(10.seconds) { puts "Timer fired!" }
#   end
# end


