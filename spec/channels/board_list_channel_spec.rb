require 'rails_helper'

RSpec.describe BoardListChannel, type: :channel do
  let!(:cm) {
    Class.new { extend CacheManager }
  }

  let(:uid) { SecureRandom.uuid }
  let(:data) {
    [
      { name: Faker::Game.title, id: SecureRandom.uuid },
      { name: Faker::Game.title, id: SecureRandom.uuid },
      { name: Faker::Game.title, id: SecureRandom.uuid },
    ]
  }
  let(:input_data) {{ board_name: Faker::Game.title, board_id: SecureRandom.uuid }}

  before do
    stub_connection(current_player_id: uid)
    boards = Rails.cache.fetch(:boards) { {} }
    boards.each_pair {|_, bid| Rails.cache.delete(bid)}
    Rails.cache.delete(:boards)
  end

  it "streams from board_list_channel when subscribed" do
    subscribe
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from('board_list_channel')
    expect(transmissions.last).to eq({
                                       "action" => "board-list:action:subscribed",
                                       "status" => "board-list:status:success",
                                       "boards" => []
                                     })
  end

  it "returns a board list of 3 when subscribing after 3 boards were created" do
    data.each { |d| cm.add_new_board(d[:name], d[:id])}
    board_list = data.map { |d| [d[:id], cm.sanitize(d[:name])]}

    subscribe
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from('board_list_channel')
    expect(transmissions.last).to eq({
                                       "action" => "board-list:action:subscribed",
                                       "status" => "board-list:status:success",
                                       "boards" => board_list
                                     })
  end

  context 'after subscribed' do
    before(:each) do
      subscribe
    end

    it 'creates a board' do
      perform :create_board, input_data
      expect(transmissions.last).to eq({
                                         "action" => "board-list:action:create",
                                         "status" => "board-list:status:success",
                                         "message" => "#{cm.sanitize(input_data[:board_name])} has been created.",
                                         "bid" => input_data[:board_id]
                                       })
    end

    it 'returns a retry status when the given name has been used previously' do
      cm.add_new_board(input_data[:board_name], input_data[:board_id])

      perform :create_board, input_data
      expect(transmissions.last).to eq({
                                         "action" => "board-list:action:create",
                                         "status" => "board-list:status:retry",
                                         "message" => "The board name #{cm.sanitize(input_data[:board_name])} exists. Choose another.",
                                       })
    end

    it 'broadcast a board list of 3 from heads_up' do
      data.each { |d| cm.add_new_board(d[:name], d[:id]) }
      board_list = data.map {|d| [d[:id], cm.sanitize(d[:name])]}

      expect {
        perform :heads_up, {
          "act": "board-list:action:howdy",
          "message": "#{cm.sanitize(data[-1][:name])} has been created."
        }
      }.to have_broadcasted_to("board_list_channel").with(
        action: 'board-list:action:howdy',
        status: 'board-list:status:success',
        boards: board_list,
        message: "#{cm.sanitize(data[-1][:name])} has been created."
      )
    end
  end


end
