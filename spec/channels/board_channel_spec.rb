require 'rails_helper'

RSpec.describe BoardChannel, type: :channel do
  let!(:cm) {
    Class.new { extend CacheManager }
  }

  let(:uid) { SecureRandom.uuid }
  let(:alice) { { name: Faker::Name.name, id: uid } }
  let(:bob) { { name: Faker::Name.name, id: SecureRandom.uuid } }
  let(:bid) { SecureRandom.uuid }
  let(:data) {
    [
      { name: Faker::Game.title, id: bid },
      { name: Faker::Game.title, id: SecureRandom.uuid },
      { name: Faker::Game.title, id: SecureRandom.uuid },
    ]
  }
  let(:input_data) {{ board_name: Faker::Game.title, board_id: bid }}

  before do
    cm.add_new_player(alice[:name], uid)
    cm.add_new_player(bob[:name], bob[:id])
    stub_connection(current_player_id: uid)
  end

  context 'with a new board' do
    before(:each) do
      cm.clear_boards
      cm.add_new_board(input_data[:board_name], input_data[:board_id])
    end

    after(:each) do
      cm.clear_boards
    end

    it 'streams from board_channel_#id when subscribed' do
      player_name = cm.find(uid).name
      subscribe board_id: bid
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from("board_channel_#{bid}")
      expect(transmissions.last).to eq({
                                         'action' => 'board:action:subscribed',
                                         'status' => 'board:status:success',
                                         'message' => "Successfully subscribed to #{cm.sanitize(input_data[:board_name])}.",
                                         'name' => cm.sanitize(input_data[:board_name]),
                                         'bid' => bid,
                                         'x_name' => player_name,
                                         'o_name' => nil,
                                         'play_result' => :go_next,
                                         'board_state' => :waiting,
                                         'board_count' => 0,
                                         'board_data' => [
                                           ['', '', ''],
                                           ['', '', ''],
                                           ['', '', ''],
                                         ],
                                       })
    end

    it 'streams from board_channel_#id when subscribed as a second player' do
      board = cm.find(bid)
      board.join(bob[:id])
      board.update_name(cm.find(bob[:id]).name, bob[:id])
      cm.replace_instance(bid, board)

      subscribe board_id: bid
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from("board_channel_#{bid}")
      expect(transmissions.last).to eq({
                                         'action' => 'board:action:subscribed',
                                         'status' => 'board:status:success',
                                         'message' => "Successfully subscribed to #{cm.sanitize(input_data[:board_name])}.",
                                         'name' => cm.sanitize(input_data[:board_name]),
                                         'bid' => bid,
                                         'x_name' => cm.find(bob[:id]).name,
                                         'o_name' => cm.find(uid).name,
                                         'play_result' => :go_next,
                                         'board_state' => :ongoing,
                                         'board_count' => 0,
                                         'board_data' => [
                                           ['', '', ''],
                                           ['', '', ''],
                                           ['', '', ''],
                                         ],
                                       })
    end

    it 'broadcasts from board_channel_#id by heads_up' do
      board = cm.find(bid)
      board.join(uid)
      board.join(bob[:id])
      board.update_name(cm.find(uid).name, uid)
      board.update_name(cm.find(bob[:id]).name, bob[:id])
      cm.replace_instance(bid, board)

      subscribe board_id: bid
      expect {
        perform :heads_up, {
          'act': 'board:action:howdy',
          'message': "A new player joined to #{board.name}.",
          'bid': bid
        }
      }.to have_broadcasted_to("board_channel_#{bid}").with(
        action: 'board:action:howdy',
        status: 'board:status:success',
        message: "A new player joined to #{board.name}.",
        bid: bid,
        x_name: cm.find(uid).name,
        o_name: cm.find(bob[:id]).name,
        play_result: 'go_next',
        board_state: 'ongoing',
        board_count: 0,
        board_data: [
          ['', '', ''],
          ['', '', ''],
          ['', '', '']
        ],
      )
    end
  end

  context 'with a new board and two players' do
    let(:board_id) { SecureRandom.uuid }

    before(:each) do
      cm.clear_boards
      cm.add_new_board(Faker::Game.title, board_id)
      board = cm.find(board_id)
      board.join(uid)
      board.join(bob[:id])
      board.update_name(cm.find(uid).name, uid)
      board.update_name(cm.find(bob[:id]).name, bob[:id])
      cm.replace_instance(board_id, board)

      subscribe board_id: board_id
    end

    after(:each) do
      cm.clear_boards
    end

    it 'broadcasts the updated state after a play' do
      expect {
        perform :play, {
          'bid': board_id,
          'x': 2,
          'y': 2,
        }
      }.to have_broadcasted_to("board_channel_#{board_id}").with(
        action: 'board:action:play',
        status: 'board:status:success',
        bid: board_id,
        play_result: 'go_next',
        board_state: 'ongoing',
        board_count: 1,
        board_data: [
          ['', '', ''],
          ['', '', ''],
          ['', '', 'x']
        ]
      )
    end
  end
end
