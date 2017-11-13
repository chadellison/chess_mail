module Api
  module V1
    class UsersController < Api::V1::BaseController
      respond_to :json

      def create
        user = User.new(user_params)

        if user.save
          user.update(token: SecureRandom.hex)
          user.send_confirmation_email

          render json: UserSerializer.serialize(user), status: 201, location: nil
        else
          render json: return_errors(user), status: 400
        end
      end

      def approve
        user = User.find_by(token: params[:token])

        if user
          user.update(approved: true)
          redirect_to ENV['host']
        else
          errors = 'Not Found'
          render json: { errors: errors }, status: 404
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :lastName, :firstName)
      end
    end
  end
end
