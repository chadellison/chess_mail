module Api
  module V1
    class MovesController < Api::V1::BaseController
      respond_to :json

      before_action :authenticate_with_token, except: :accept

      def create
        game = Game.find(params[:game_id])
        game.handle_move(move_params, @user) unless game.outcome.present?
        serialized_game = { data: GameSerializer.serialize(game.reload, @user.email) }
        render json: serialized_game, status: 201
      end

      private

      def move_params
        params.require(:move).permit(:currentPosition, :startIndex, :pieceType,
                                     :notation)
      end
    end
  end
end
