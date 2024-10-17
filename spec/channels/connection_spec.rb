# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:uid) { SecureRandom.uuid }

  it 'should successfully connect with a cookie' do
    cookies.encrypted[:tictactoe_player_id] = uid
    connect "/cable", headers: { "Cookie" => cookies }
    expect(connection.current_player_id).to eq(uid)
  end

  it "should raise error without a cookies" do
    expect { connect "/cable" }.to have_rejected_connection
  end
end

