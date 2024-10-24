require 'rails_helper'

RSpec.describe PlayerChannel, type: :channel do
  let!(:cm) {
    Class.new { extend CacheManager }
  }

  let(:uid) { SecureRandom.uuid }

  before do
    stub_connection(current_player_id: uid)
    players = Rails.cache.fetch(:players) { {} }
    players.each_pair {|_, pid| Rails.cache.delete(pid)}
    Rails.cache.delete(:players)
  end

  it "subscribes and stream for player_channel" do
    subscribe player: ""
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from('player_channel')
    expect(transmissions.last).to eq({
                                       "action" => "player:action:subscribed",
                                       "status" => "player:status:non-existing",
                                       "players" => []
    })
  end

  context 'after 3 players were registered' do
    let(:data) {
      [
        {name: Faker::Name.name, id: uid},
        {name: Faker::Name.name, id: SecureRandom.uuid},
        {name: Faker::Name.name, id: SecureRandom.uuid}
      ]
    }

    before(:each) do
      data.each {|d| cm.add_new_player(d[:name], d[:id])}
    end

    after(:each) do
      Rails.cache.delete(:players)
      data.each {|d| Rails.cache.delete(d[:id])}
    end

    it 'returns a player list of 3 from subscribe' do
      player_list = data.map {|d| cm.sanitize(d[:name])}
      subscribe player: ""
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from('player_channel')
      expect(transmissions.last).to eq({
                                         "action" => "player:action:subscribed",
                                         "status" => "player:status:non-existing",
                                         "players" => player_list
                                       })
    end

    it 'returns the status of existing from subscription when a registered player name is given' do
      player_list = data.map {|d| cm.sanitize(d[:name])}
      subscribe player: data[0][:name]
      expect(transmissions.last).to eq({
                                         "action" => "player:action:subscribed",
                                         "status" => "player:status:existing",
                                         "players" => player_list
                                       })
    end

    it 'broadcasts a player list of 2 from unsubscribe' do
      player_list = data[1..-1].map {|d| cm.sanitize(d[:name])}
      subscribe player: data[0][:name]
      expect {
        unsubscribe
      }.to have_broadcasted_to("player_channel").with(
        action: 'player:action:unsubscribed',
        status: 'player:status:success',
        players: player_list,
      )
    end

    it 'broadcast a player list of 3 from heads_up' do
      player_list = data.map {|d| cm.sanitize(d[:name])}
      subscribe player: ""
      expect {
        perform :heads_up, {"act": "player:action:howdy", "message": "#{cm.sanitize(data[0][:name])} has joined." }
      }.to have_broadcasted_to("player_channel").with(
        action: 'player:action:howdy',
        status: 'player:status:success',
        players: player_list,
        message: "#{cm.sanitize(data[0][:name])} has joined."
      )
    end
  end

  context 'starting from 0 player' do
    let(:data) {
      [
        {name: Faker::Name.name, id: uid},
        {name: Faker::Name.name, id: SecureRandom.uuid},
        {name: Faker::Name.name, id: SecureRandom.uuid}
      ]
    }

    before(:each) do
      subscribe player: ""
    end

    after(:each) do
      Rails.cache.delete(:players)
      data.each {|d| Rails.cache.delete(d[:id])}
    end

    it 'registers a player' do
      perform :register, { player: data[0][:name] }
      expect(transmissions.last).to eq({
                                         "action" => "player:action:register",
                                         "status" => "player:status:success",
                                         "message" => "#{cm.sanitize(data[0][:name])} has been registered successfully."
                                       })
    end

    it 'returns retry status when the same player name is given' do
      cm.add_new_player(data[0][:name], data[0][:id])
      perform :register, { player: data[0][:name] }
      expect(transmissions.last).to eq({
                                         "action" => "player:action:register",
                                         "status" => "player:status:retry",
                                         "message" => "The player name #{cm.sanitize(data[0][:name])} exists. Choose another."
                                       })
    end

    it 'unregisters a player' do
      data.each {|d| cm.add_new_player(d[:name], d[:id])}
      player_list = data[1..-1].map {|d| cm.sanitize(d[:name])}
      perform :unregister
      expect(transmissions.last).to eq({
                                         "action" => "player:action:unregister",
                                         "status" => "player:status:success",
                                         "players" => player_list
                                       })
    end
  end
end
