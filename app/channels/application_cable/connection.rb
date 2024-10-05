module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_player_id

    def connect
      self.current_player_id = find_valid_player_id
    end

    def disconnect
      # Any cleanup work needed when the cable connection is cut.)
      cookies.delete(:tictactoe_player_id)
    end

    private
    def find_valid_player_id
      if valid_id = cookies.encrypted[:tictactoe_player_id]
        valid_id
      else
        reject_unauthorized_connection
      end
    end
  end
end
