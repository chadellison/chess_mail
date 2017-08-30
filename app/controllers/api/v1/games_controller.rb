module Api
  module V1
    class GamesController < Api::V1::BaseController
      respond_to :json

      before_action :authenticate_with_token

      def index
        respond_with Game.serialize_games(@user.games)
      end

      def show
        game = @user.games.find(params[:id])
        serialized_game = { data: game.serialize_game }

        respond_with serialized_game
      end
    end
  end
end
