module Api
  module V1
    class MovesController < Api::V1::BaseController
      respond_to :json

      before_action :authenticate_with_token, except: :accept

      def create
        game = Game.find(params[:game_id])
        piece = game.pieces.create(piece_params)
        game.send_new_move_email(piece, @user)

        serialized_game = { data: game.serialize_game(@user.email) }
        render json: serialized_game, status: 201
      end

      private

      def piece_params
        params.require(:piece).permit(:pieceType, :color, :currentPosition,
                                      :hasMoved, :movedTwo, :startIndex)
      end
    end
  end
end
