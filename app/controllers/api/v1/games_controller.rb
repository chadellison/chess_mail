module Api
  module V1
    class GamesController < Api::V1::BaseController
      respond_to :json

      before_action :authenticate_with_token, except: :accept

      def index
        respond_with Game.serialize_games(@user.games, @user.email)
      end

      def show
        serialized_game = { data: find_game.serialize_game(@user.email) }

        respond_with serialized_game
      end

      def create
        game = Game.handle_game_creation(@user, game_params)

        if game[:error].blank?
          serialized_game = { data: game.serialize_game(@user.email) }
          render json: serialized_game, status: 201
        else
          render json: game, status: 400
        end
      end

      def update
        piece = Piece.find_or_create_by(piece_params)
        find_game.pieces << piece

        render status: 204
      end

      def accept
        challenged_user = User.find_by(token: params[:token])

        if challenged_user
          game = challenged_user.games.find(params[:game_id])
          game.update(pending: false) if challenged_user.email == game.challenged_email
        else
          redirect_to ENV['host']
        end
      end

      private

      def find_game
        @user.games.find(params[:id])
      end

      def piece_params
        params.require(:piece).permit(:id, :pieceType, :color, :currentPosition)
      end

      def game_params
        params.require(:game).permit(:challengedName, :challengedEmail,
                                     :playerColor, :challengePlayer,
                                     :challengeRobot)
      end
    end
  end
end
