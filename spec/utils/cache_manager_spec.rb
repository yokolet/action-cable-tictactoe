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
    let(:data) {
      [
        {name: Faker::Name.name, id: SecureRandom.uuid},
        {name: Faker::Name.name, id: SecureRandom.uuid},
        {name: Faker::Name.name, id: SecureRandom.uuid}
      ]
    }

    before(:each) do
      players = {}
      data.each do |h|
        name = cm.sanitize(h[:name])
        players[cm.to_key(name)] = h[:id]
        Rails.cache.write(h[:id], Player.new(name))
      end
      Rails.cache.write(:players, players)
    end

    after(:each) do
      players = Rails.cache.read(:players)
      players.each_pair do |_, pid|
        Rails.cache.delete(pid)
      end
      Rails.cache.delete(:players)
    end

    it 'finds 3 players' do
      result = cm.current_players
      expect(result.length).to eq(3)
      keys = data.map {|h| cm.to_key(cm.sanitize(h[:name]))}
      expect(result.keys).to eq(keys)
    end

    it 'finds 2 players after deleting one player' do
      Rails.cache.delete(data[-1][:id])
      result = cm.current_players
      expect(result.length).to eq(2)
    end

    it 'returns 3 player names' do
      result = cm.current_player_list
      expect(result).to eq(data.map {|h| cm.sanitize(h[:name])})
    end

    it 'returns 2 player names after deleting one player' do
      Rails.cache.delete(data[0][:id])
      result = cm.current_player_list
      expect(result).to eq(data[1..-1].map {|h| cm.sanitize(h[:name])})
    end

    it 'checks if the given player name is already registered' do
      result = cm.existing_player?("Hello World")
      expect(result).to be_falsey
      result = cm.existing_player?(data[1][:name])
      expect(result).to be_truthy
    end
  end

  context 'while the application is used' do
    let(:pid) { SecureRandom.uuid }

    describe 'has a feature to' do
      after(:each) do
        players = Rails.cache.read(:players)
        players.each_pair do |_, pid|
          Rails.cache.delete(pid)
        end
        Rails.cache.delete(:players)
      end

      it 'add a new player' do
        cm.add_new_player(Faker::Name.name, pid)
        result = Rails.cache.read(:players)
        expect(result.length).to eq(1)
        result.each_pair do |key, id|
          player = Rails.cache.read(id)
          expect(player).not_to be_nil
          expect(cm.to_key(player.name)).to eq(key)
        end
      end
    end

    describe 'has another feature to' do
      before(:each) do
        name = cm.sanitize(Faker::Name.name)
        pkey = cm.to_key(name)
        players = {pkey => pid}
        Rails.cache.write(:players, players)
        Rails.cache.write(pid, Player.new(name))
      end

      after(:each) do
        Rails.cache.delete(pid)
        Rails.cache.delete(:players)
      end

      it 'delete a player' do
        cm.delete_player(pid)
        result = Rails.cache.read(:players)
        expect(result.length).to eq(0)
        player = Rails.cache.read(pid)
        expect(player).to be_nil
      end
    end

  end

  context 'when 3 boards have been created' do
    let(:data) {
      [
        {name: Faker::Game.title, id: SecureRandom.uuid},
        {name: Faker::Game.title, id: SecureRandom.uuid},
        {name: Faker::Game.title, id: SecureRandom.uuid}
      ]
    }

    before(:each) do
      boards = {}
      data.each do |h|
        name = cm.sanitize(h[:name])
        boards[cm.to_key(name)] = h[:id]
        Rails.cache.write(h[:id], TicTacToeBoard.new(name))
      end
      Rails.cache.write(:boards, boards)
    end

    after(:each) do
      boards = Rails.cache.read(:boards)
      boards.each_pair do |_, pid|
        Rails.cache.delete(pid)
      end
      Rails.cache.delete(:boards)
    end

    it 'finds 3 boards' do
      result = cm.current_boards
      expect(result.length).to eq(3)
      keys = data.map {|h| cm.to_key(cm.sanitize(h[:name]))}
      expect(result.keys).to eq(keys)
    end

    it 'finds 2 boards after deleting one board' do
      Rails.cache.delete(data[-1][:id])
      result = cm.current_boards
      expect(result.length).to eq(2)
    end

    it 'returns 3 board id and name pairs' do
      result = cm.current_board_list
      expect(result).to eq(data.map {|h| [h[:id], cm.sanitize(h[:name])]})
    end

    it 'returns 2 board id and name pairs after deleting one board' do
      Rails.cache.delete(data[0][:id])
      result = cm.current_board_list
      expect(result).to eq(data[1..-1].map {|h| [h[:id], cm.sanitize(h[:name])]})
    end

    it 'checks if the given board name is already used' do
      result = cm.existing_board?("Hello World")
      expect(result).to be_falsey
      result = cm.existing_board?(data[1][:name])
      expect(result).to be_truthy
    end
  end

  context 'while the application is used' do
    let(:bid) { SecureRandom.uuid }

    describe 'has a feature to' do
      after(:each) do
        boards = Rails.cache.read(:boards)
        boards.each_pair do |_, bid|
          Rails.cache.delete(bid)
        end
        Rails.cache.delete(:boards)
      end

      it 'add a new board' do
        cm.add_new_board(Faker::Game.title, bid)
        result = Rails.cache.read(:boards)
        expect(result.length).to eq(1)
        result.each_pair do |key, id|
          board = Rails.cache.read(id)
          expect(board).not_to be_nil
          expect(cm.to_key(board.name)).to eq(key)
        end
      end
    end

    describe 'has another feature to' do
      before(:each) do
        name = cm.sanitize(Faker::Game.title)
        bkey = cm.to_key(name)
        boards = {bkey => bid}
        Rails.cache.write(:boards, boards)
        Rails.cache.write(bid, TicTacToeBoard.new(name))
      end

      after(:each) do
        Rails.cache.delete(bid)
        Rails.cache.delete(:boards)
      end

      it 'delete a player' do
        cm.delete_board(bid)
        result = Rails.cache.read(:boards)
        expect(result.length).to eq(0)
        board = Rails.cache.read(bid)
        expect(board).to be_nil
      end
    end
  end
end
