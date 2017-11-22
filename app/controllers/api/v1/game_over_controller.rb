module Api
  module V1
    class GameOverController < Api::V1::BaseController
      respond_to :json

      before_action :authenticate_with_token, only: [:update]
      before_action :find_game, only: [:update]

      def update
        if params[:resign].present?
          @game.handle_resign(@user)
        else
          # needs backend validation to match outcome param
          @game.update(outcome: handle_outcome(params[:outcome]))
        end

        serialized_game = { data: GameSerializer.serialize(@game, @user.email) }
        render json: serialized_game, status: 201
      end

      private

      def handle_outcome(outcome)
        { 'white wins' => 1, 'black wins' => -1, 'draw' => 0 }[outcome]
      end
    end
  end
end
