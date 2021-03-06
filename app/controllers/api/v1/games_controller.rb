module Api
  module V1
    class GamesController < Api::V1::BaseController
      respond_to :json

      before_action :authenticate_with_token, except: [:create_ai_game]
      before_action :find_game, only: [:show, :destroy]
      before_action :validate_challenged_email, only: :create

      def index
        render json: { data: UserSerializer.serialized_user_games(@user, params[:page]) }
      end

      def show
        render json: { data: GameSerializer.serialize(@game, @user.email) }
      end

      def create
        game = @user.games.create(game_params)

        if game.valid?
          
          game.setup(@user)
          serialized_game = { data: GameSerializer.serialize(game, @user.email) }
          render json: serialized_game, status: 201
        else
          render json: return_errors(game), status: 400
        end
      end

      def create_ai_game
        game = Game.new(human: false, robot: true)
        game.save(validate: false)
        serialized_game = { data: GameSerializer.serialize(game) }
        render json: serialized_game, status: 201
      end

      def destroy
        @game.handle_archive(@user)
      end

      private

      def game_params
        params.require(:game).permit(:challengedName, :challengedEmail,
                                     :challengerColor, :human, :robot)
      end

      def validate_challenged_email
        if game_params[:challengedEmail] == @user.email
          error = { errors: 'Your opponent must be someone other than yourself.' }
          render json: error, status: 400
        end
      end
    end
  end
end
