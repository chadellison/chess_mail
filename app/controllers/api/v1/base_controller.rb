module Api
  module V1
    class BaseController < ApplicationController
      def authenticate_with_token
        @user = User.find_by(token: params[:token])

        unless @user.present? && @user.approved
          raise ActiveRecord::RecordNotFound
        end
      end

      def find_game
        @game = @user.games.find(params[:id])
      end

      def return_errors(resource)
        {
          errors: resource.errors.map do |key, value|
            "#{key} #{value}"
          end.join("\n")
        }
      end
    end
  end
end
