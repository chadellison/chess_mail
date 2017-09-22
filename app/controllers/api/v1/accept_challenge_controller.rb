module Api
  module V1
    class AcceptChallengeController < Api::V1::BaseController
      respond_to :json

      def show
        challenged_user = User.find_by(token: params[:token])

        if challenged_user
          game = Game.where(challengedEmail: challenged_user.email).find(params[:id])
          game.update(pending: false)
        end

        handle_response
      end

      private

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
