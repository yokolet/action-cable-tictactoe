require 'rails_helper'

RSpec.describe PlayerChannel, type: :channel do
  before { subscribe }

  xit "subscribes and stream for player_channel" do
      expect(subscription.confirmed?).to be_truthy
      expect(assert_has_stream 'player_channel').to be_truthy
    end
end
