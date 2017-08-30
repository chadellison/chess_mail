module Api
  module V1
    class GamesController < Api::V1::BaseController
      respond_to :json

      before_action :authenticate_with_token

      def index
        user = User.find(params[:user_id])

        respond_with Game.serialize_games(user.games)
      end
    end
  end
end
