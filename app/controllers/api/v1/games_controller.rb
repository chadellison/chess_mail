module Api
  module V1
    class GamesController < Api::V1::BaseController
      respond_to :json

      before_action :authenticate_with_token, except: :accept

      def index
        respond_with Game.serialize_games(@user.games)
      end

      def show
        serialized_game = { data: find_game.serialize_game }

        respond_with serialized_game
      end

      def create
        # check if game vs oppoenent has been created already
        # check if proper game params have been given
        # handle errors
        game = @user.games.create
        game.setup(@user, game_params)
        serialized_game = { data: game.serialize_game }

        render json: serialized_game, status: 201
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
          game.update(pending: false) if challenged_user.id == game.challenged_id
        else
          redirect_to ENV['host']
        end
      end

      private

      def find_game
        @user.games.find(params[:id])
      end

      def game_params
        params.require(:game).permit(:challengedName, :challengedEmail,
                                     :playerColor, :challengePlayer,
                                     :challengeRobot)
      end

      def piece_params
        params.require(:piece).permit(:id, :pieceType, :color, :currentPosition)
      end
    end
  end
end
