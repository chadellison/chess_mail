module Api
  module V1
    class GamesController < Api::V1::BaseController
      respond_to :json

      before_action :authenticate_with_token

      def index
        respond_with Game.serialize_games(@user.games)
      end

      def show
        serialized_game = { data: find_game.serialize_game }

        respond_with serialized_game
      end

      def update
        piece = Piece.find_or_create_by(piece_params)
        find_game.pieces << piece

        render status: 204
      end

      private

      def find_game
        @user.games.find(params[:id])
      end

      def piece_params
        params.require(:piece).permit(:id, :pieceType, :color, :currentPosition)
      end
    end
  end
end
