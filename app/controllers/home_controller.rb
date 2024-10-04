class HomeController < ApplicationController
  def index
    cookies.encrypted[:tictactoe_player_id] = {
      value: SecureRandom.uuid,
      expires: 2.hours,
      http_only: false
    }
  end
end
