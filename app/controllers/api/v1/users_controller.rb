module Api
  module V1
    class UsersController < ApplicationController
      respond_to :json

      def create
        user = User.new(user_params)

        if user.save
          render nothing: true, status: 201, location: nil
        else
          errors = user.errors.map { |key, value| "#{key} #{value}" }.join("\n")
          render json: { errors: errors }, status: 400
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :password)
      end
    end
  end
end
