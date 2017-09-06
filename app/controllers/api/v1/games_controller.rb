module Api
  module V1
    class GamesController < Api::V1::BaseController
      respond_to :json

      before_action :authenticate_with_token, except: :accept

      def index
        render json: Game.serialize_games(@user.games, @user.email)
      end

      def show
        serialized_game = { data: find_game.serialize_game(@user.email) }

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

      def update
        piece = Piece.find_or_create_by(piece_params)
        find_game.pieces << piece

        render status: 204
      end

      def accept
        challenged_user = User.find_by(token: params[:token])

        if challenged_user
          game = Game.where(challengedEmail: challenged_user.email).find(params[:game_id])
          game.update(pending: false)
        end

        redirect_to ENV['host']
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
                                     :challengerColor, :human)
      end

      def return_errors(game)
        {
          errors: game.errors.map do |key, value|
            "#{key} #{value}"
          end.join("\n")
        }
      end
    end
  end
end
