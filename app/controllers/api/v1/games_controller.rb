module Api
  module V1
    class GamesController < Api::V1::BaseController
      respond_to :json

      before_action :authenticate_with_token, except: :accept
      before_action :find_game, only: [:show, :move, :end_game, :destroy]
      before_action :validate_challenged_email, only: :create

      def index
        render json: { data: @user.serialized_user_games }
      end

      def show
        serialized_game = { data: @game.serialize_game(@user.email) }

        respond_with serialized_game
      end

      def create
        game = @user.games.create(game_params)

        if game.valid?
          game.setup(@user)
          serialized_game = { data: game.serialize_game(@user.email) }
          render json: serialized_game, status: 201
        else
          render json: return_errors(game), status: 400
        end
      end

      def move
        piece = Piece.find_or_create_by(piece_params)
        @game.pieces << piece
        @game.send_new_move_email(piece, @user)

        serialized_game = { data: @game.serialize_game(@user.email) }
        render json: serialized_game, status: 201
      end

      def end_game
        if params[:resign].present?
          @game.handle_resign(@user)
        else
          # needs backend validation to match outcome param
          @game.update(outcome: params[:outcome])
        end

        serialized_game = { data: @game.serialize_game(@user.email) }
        render json: serialized_game, status: 201
      end

      def destroy
        @game.destroy if @game.pending
        @user.archives.create(game_id: @game.id) if @game.outcome.present?
      end

      def accept
        challenged_user = User.find_by(token: params[:token])

        if challenged_user
          game = Game.where(challengedEmail: challenged_user.email).find(params[:game_id])
          game.update(pending: false)
        end

        handle_response
      end

      private

      def find_game
        @game = @user.games.find(params[:id])
      end

      def piece_params
        params.require(:piece).permit(:pieceType, :color, :currentPosition,
                                      :hasMoved, :movedTwo, :startIndex)
      end

      def game_params
        params.require(:game).permit(:challengedName, :challengedEmail,
                                     :challengerColor, :human)
      end

      def validate_challenged_email
        if game_params[:challengedEmail] == @user.email
          error = { errors: 'Your opponent must be someone other than yourself.' }
          render json: error, status: 400
        end
      end

      def handle_response
        if params[:from_email].present?
          redirect_to ENV['host']
        else
          render status: 204
        end
      end
    end
  end
end
