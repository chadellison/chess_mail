module Api
  module V1
    class MovesController < Api::V1::BaseController
      respond_to :json

      before_action :authenticate_with_token, only: [:create]
      before_action :find_game

      def create
        @game.handle_move(move_params, @user) unless @game.outcome.present?
        serialized_game = { data: GameSerializer.serialize(@game.reload, @user.email) }
        render json: serialized_game, status: 201
      end

      def show
        @game.ai_move
        serialized_game = { data: GameSerializer.serialize(@game.reload) }
        render json: serialized_game, status: 201
      end

      private

      def find_game
        @game = Game.find(params[:id])
      end

      def move_params
        params.require(:move).permit(:currentPosition, :startIndex, :pieceType,
                                     :notation)
      end
    end
  end
end
