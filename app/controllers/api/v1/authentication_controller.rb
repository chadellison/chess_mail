module Api
  module V1
    class AuthenticationController < Api::V1::BaseController
      respond_to :json

      def create
        user = User.find_by(email: login_params[:email].downcase)

        if user && user.authenticate(login_params[:password]) && user.approved
          user.update(token: SecureRandom.hex)
          respond_with user.serialize_user, location: nil, status: 201
        else
          error = ActiveRecord::RecordNotFound
          message = { errors: "Invalid Credentials" }
          respond_with message, location: nil, status: 404
        end
      end

      private

      def login_params
        params.require(:credentials).permit(:email, :password)
      end
    end
  end
end
