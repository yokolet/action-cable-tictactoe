require 'rails_helper'

RSpec.describe PlayerChannel, type: :channel do
  let!(:cm) {
    Class.new { extend CacheManager }
  }

  before { Rails.cache.clear }

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
        {name: Faker::Name.name, id: SecureRandom.uuid},
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

    it 'returns a player list of 3' do
      player_list = data.map {|d| cm.sanitize(d[:name])}
      subscribe player: ""
      expect(transmissions.last).to eq({
                                         "action" => "player:action:subscribed",
                                         "status" => "player:status:non-existing",
                                         "players" => player_list
                                       })
    end
  end


end
