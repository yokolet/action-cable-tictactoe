require 'rails_helper'

RSpec.describe BoardListChannel, type: :channel do
  let!(:cm) {
    Class.new { extend CacheManager }
  }

  let(:uid) { SecureRandom.uuid }

  before do
    stub_connection(current_player_id: uid)
    boards = Rails.cache.fetch(:boards) { {} }
    boards.each_pair {|_, bid| Rails.cache.delete(bid)}
    Rails.cache.delete(:boards)
  end

  it "streams for board_list_channel when subscribed" do
    subscribe
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from('board_list_channel')
    expect(transmissions.last).to eq({
                                       "action" => "board-list:action:subscribed",
                                       "status" => "board-list:status:success",
                                       "boards" => []
                                     })
  end


end
