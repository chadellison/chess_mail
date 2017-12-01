module Api
  module V1
    class MovesController < Api::V1::BaseController
      respond_to :json

      before_action :authenticate_with_token, only: [:create]

      def create
        game = Game.find(params[:game_id])
        game.handle_move(move_params, @user) unless game.outcome.present?
        serialized_game = { data: GameSerializer.serialize(game.reload, @user.email) }
        render json: serialized_game, status: 201
      end

      def create_ai_move
        game = Game.find_by(move_signature: ai_move_params[:move_signature], robot: true, human: false)
        game.ai_move
        render json: { data: game.moves.map { |move| MoveSerializer.serialize(move) } }
      end

      private

      def move_params
        params.require(:move).permit(:currentPosition, :startIndex, :pieceType,
                                     :notation)
      end

      def ai_move_params
        params.require(:move).permit(:move_signature)
      end
    end
  end
end
