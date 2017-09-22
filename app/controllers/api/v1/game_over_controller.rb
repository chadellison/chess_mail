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
          @game.update(outcome: params[:outcome])
        end

        serialized_game = { data: @game.serialize_game(@user.email) }
        render json: serialized_game, status: 201
      end
    end
  end
end
