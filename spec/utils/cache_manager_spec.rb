# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "CacheManager", type: :util do
  let!(:cm) {
    Class.new { extend CacheManager }
  }

  it 'sanitizes a string' do
    expect(cm.sanitize("D'Arcy")).to eq("D'Arcy")
    expect(cm.sanitize("    a    b    c   ")).to eq("a b c")
    expect(cm.sanitize("<img src='picture.jpg' />")).to eq("img src'picturejpg'")
    expect(cm.sanitize("loooooooooooooooooooooong    naaaaaaaaaaaaaaaaame").length).to eq(30)
    expect(cm.sanitize("'); comment--;")).to eq("' comment--")
  end

  it 'returns a key from a given string' do
    expect(cm.to_key("D'Arcy")).to eq(:"d'arcy")
    expect(cm.to_key("Alice")).to eq(:alice)
    expect(cm.to_key("a b c")).to eq(:"a b c")
  end

  context 'when 3 players have been registered' do
    let(:pkey) { :players_cm_1 }
    let(:data) {
      [
        {name: Faker::Name.name, id: SecureRandom.uuid},
        {name: Faker::Name.name, id: SecureRandom.uuid},
        {name: Faker::Name.name, id: SecureRandom.uuid}
      ]
    }

    before(:each) do
      players = {}
      data.each do |d|
        name = cm.sanitize(d[:name])
        players[cm.to_key(name)] = d[:id]
        Rails.cache.write(d[:id], Player.new(name))
      end
      Rails.cache.write(pkey, players)
    end

    after(:each) do
      players = Rails.cache.fetch(pkey) { {} }
      players.each_pair do |_, pid|
        Rails.cache.delete(pid)
      end
      Rails.cache.delete(pkey)
    end

    it 'finds a player of given id' do
      result = cm.find(data[0][:id])
      expect(result.is_a?(Player)).to be_truthy
      expect(result.name).to eq(cm.sanitize(data[0][:name]))
    end

    it 'finds 3 players' do
      result = cm.current_instances(pkey)
      expect(result.length).to eq(3)
      keys = data.map {|d| cm.to_key(cm.sanitize(d[:name]))}
      expect(result.keys).to eq(keys)
    end

    it 'returns 3 player names' do
      result = cm.current_instance_list(pkey)
      expect(result).to eq(data.map {|d| cm.sanitize(d[:name])})
    end

    it 'returns 2 player names after deleting one player' do
      Rails.cache.delete(data[0][:id])
      result = cm.current_instance_list(pkey)
      expect(result).to eq(data[1..-1].map {|d| cm.sanitize(d[:name])})
    end

    it 'checks if the given player name is already registered' do
      result = cm.available_instance?("Hello World", pkey)
      expect(result[:status]).to be_truthy
      result = cm.available_instance?(data[1][:name], pkey)
      expect(result[:status]).to be_falsey
    end
  end

  context 'while the application is used' do
    describe 'has a feature to' do
      let(:pkey) { :players_cm_2 }
      let(:pid) { SecureRandom.uuid }

      after(:each) do
        players = Rails.cache.fetch(pkey) { {} }
        players.each_pair do |_, pid|
          Rails.cache.delete(pid)
        end
        Rails.cache.delete(pkey)
      end

      it 'add a new player' do
        cm.add_new(Faker::Name.name, pid, pkey, Player)
        result = Rails.cache.read(pkey)
        expect(result.length).to eq(1)
        result.each_pair do |key, id|
          player = Rails.cache.read(id)
          expect(player).not_to be_nil
          expect(cm.to_key(player.name)).to eq(key)
        end
      end
    end

    describe 'has another feature to' do
      let(:pkey) { :players_cm_3 }
      let(:pid) { SecureRandom.uuid }

      before(:each) do
        name = cm.sanitize(Faker::Name.name)
        key = cm.to_key(name)
        players = {key => pid}
        Rails.cache.write(pkey, players)
        Rails.cache.write(pid, Player.new(name))
      end

      after(:each) do
        Rails.cache.delete(pid)
        Rails.cache.delete(pkey)
      end

      it 'delete a player' do
        previous = Rails.cache.read(pkey)
        cm.delete_instance(pid, pkey)
        result = Rails.cache.read(pkey)
        expect(result.length).to eq(previous.length - 1)
        player = Rails.cache.read(pid)
        expect(player).to be_nil
      end
    end
  end

  context 'when 3 boards have been created' do
    let(:bkey) { :boards_cm_1 }
    let(:data) {
      [
        {name: Faker::Game.title, id: SecureRandom.uuid},
        {name: Faker::Game.title, id: SecureRandom.uuid},
        {name: Faker::Game.title, id: SecureRandom.uuid}
      ]
    }

    before(:each) do
      boards = {}
      data.each do |d|
        name = cm.sanitize(d[:name])
        boards[cm.to_key(name)] = d[:id]
        Rails.cache.write(d[:id], TicTacToeBoard.new(name))
      end
      Rails.cache.write(bkey, boards)
    end

    after(:each) do
      boards = Rails.cache.fetch(bkey) { {} }
      boards.each_pair do |_, bid|
        Rails.cache.delete(bid)
      end
      Rails.cache.delete(bkey)
    end

    it 'finds a board given id' do
      result = cm.find(data[0][:id])
      expect(result.is_a?(TicTacToeBoard)).to be_truthy
      expect(result.name).to eq(cm.sanitize(data[0][:name]))
    end

    it 'finds 3 boards' do
      result = cm.current_instances(bkey)
      expect(result.length).to eq(3)
      keys = data.map {|d| cm.to_key(cm.sanitize(d[:name]))}
      expect(result.keys).to eq(keys)
    end

    it 'returns 3 board id and name pairs' do
      result = cm.current_instance_pair_list(bkey)
      expect(result).to eq(data.map {|d| [d[:id], cm.sanitize(d[:name])]})
    end

    it 'checks if the given board name is already used' do
      result = cm.available_instance?("Hello World", bkey)
      expect(result[:status]).to be_truthy
      result = cm.available_instance?(data[1][:name], bkey)
      expect(result[:status]).to be_falsey
    end
  end

  context 'when 3 boards have been created for another occasion' do
    let(:bkey) { :boards_cm_2 }
    let(:data) {
      [
        {name: Faker::Game.title, id: SecureRandom.uuid},
        {name: Faker::Game.title, id: SecureRandom.uuid},
        {name: Faker::Game.title, id: SecureRandom.uuid}
      ]
    }

    before(:each) do
      boards = {}
      data.each do |d|
        name = cm.sanitize(d[:name])
        boards[cm.to_key(name)] = d[:id]
        Rails.cache.write(d[:id], TicTacToeBoard.new(name))
      end
      Rails.cache.write(bkey, boards)
    end

    after(:each) do
      boards = Rails.cache.fetch(bkey) { {} }
      boards.each_pair do |_, bid|
        Rails.cache.delete(bid)
      end
      Rails.cache.delete(bkey)
    end

    it 'finds 2 boards after deleting one board' do
      Rails.cache.delete(data[-1][:id])
      result = cm.current_instances(bkey)
      expect(result.length).to eq(2)
      result = cm.current_instance_pair_list(bkey)
      expect(result).to eq(data[0...-1].map {|d| [d[:id], cm.sanitize(d[:name])]})
    end
  end

  context 'while the application is used' do
    describe 'has a feature to' do
      let(:bkey) { :boards_cm_3 }
      let(:bid) { SecureRandom.uuid }

      after(:each) do
        boards = Rails.cache.fetch(bkey) { {} }
        boards.each_pair do |_, bid|
          Rails.cache.delete(bid)
        end
        Rails.cache.delete(bkey)
      end

      it 'add a new board' do
        cm.add_new(Faker::Game.title, bid, bkey, TicTacToeBoard)
        result = Rails.cache.read(bkey)
        expect(result.length).to eq(1)
        result.each_pair do |key, id|
          board = Rails.cache.read(id)
          expect(board).not_to be_nil
          expect(cm.to_key(board.name)).to eq(key)
        end
      end
    end

    describe 'has another feature to' do
      let(:bkey) { :boards_cm_4 }
      let(:bid) { SecureRandom.uuid }

      before(:each) do
        Rails.cache.delete(bid)
        Rails.cache.delete(bkey)
        name = cm.sanitize(Faker::Game.title)
        key = cm.to_key(name)
        boards = {key => bid}
        Rails.cache.write(bkey, boards)
        Rails.cache.write(bid, TicTacToeBoard.new(name))
      end

      after(:each) do
        Rails.cache.delete(bid)
        Rails.cache.delete(bkey)
      end

      it 'delete a board' do
        previous = Rails.cache.read(bkey)
        cm.delete_instance(bid, bkey)
        result = Rails.cache.read(bkey)
        expect(result.length).to eq(previous.length - 1)
        board = Rails.cache.read(bid)
        expect(board).to be_nil
      end
    end
  end

  context 'after 3 players were registered' do
    let(:pkey) { :players_cm_4 }
    let(:player_data) {
      [
        {name: Faker::Name.name, id: SecureRandom.uuid},
        {name: Faker::Name.name, id: SecureRandom.uuid},
        {name: Faker::Name.name, id: SecureRandom.uuid}
      ]
    }

    before(:each) do
      player_data.each { |d| cm.add_new(d[:name], d[:id], pkey, Player)  }
    end

    it 'clears 3 players' do
      players = cm.current_instances(pkey)
      expect(players.length).to eq(3)
      cm.clear_instances(pkey)
      players = cm.current_instances(pkey)
      expect(players.length).to eq(0)
    end
  end

  context 'after 20 players were registered' do
    let(:pkey) { :players_cm_5 }

    before(:each) do
      20.times {
        cm.add_new(Faker::Name.name, SecureRandom.uuid, pkey, Player)
      }
    end

    after(:each) do
      players = Rails.cache.fetch(pkey) { {} }
      players.values.each { |id| Rails.cache.delete(id) }
      Rails.cache.delete(pkey)
    end

    it 'does not allow 21th player to register' do
      players = cm.current_instances(pkey)
      expect(players.length).to eq(20)
      availability = cm.available_instance?(Faker::Name.name, pkey)
      expect(availability[:status]).to be_falsey
      expect(availability[:reason]).to eq(:max_number)
    end
  end

  context 'after 3 boards were created' do
    let(:bkey) { :boards_cm_5 }
    let(:board_data) {
      [
        {name: Faker::Game.title, id: SecureRandom.uuid},
        {name: Faker::Game.title, id: SecureRandom.uuid},
        {name: Faker::Game.title, id: SecureRandom.uuid}
      ]
    }

    before(:each) do
      board_data.each { |d| cm.add_new(d[:name], d[:id], bkey, TicTacToeBoard)  }
    end

    it 'clears 3 boards' do
      boards = cm.current_instances(bkey)
      expect(boards.length).to eq(3)
      cm.clear_instances(bkey)
      boards = cm.current_instances(bkey)
      expect(boards.length).to eq(0)
    end
  end

  context 'after 20 boards were created' do
    let(:bkey) { :boards_cm_6 }

    before(:each) do
      20.times {
        cm.add_new(Faker::Game.title, SecureRandom.uuid, bkey, TicTacToeBoard)
      }
    end

    after(:each) do
      boards = Rails.cache.fetch(bkey) { {} }
      boards.values.each { |id| Rails.cache.delete(id) }
      Rails.cache.delete(bkey)
    end

    it 'does not allow 21th player to register' do
      boards = cm.current_instances(bkey)
      expect(boards.length).to eq(20)
      availability = cm.available_instance?(Faker::Game.title, bkey)
      expect(availability[:status]).to be_falsey
      expect(availability[:reason]).to eq(:max_number)
    end
  end
end
