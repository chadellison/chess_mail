module Api
  module V1
    class BaseController < ApplicationController
      def authenticate_with_token
        @user = User.find_by(password_digest: params[:token])

        unless @user.present? && @user.approved
          return raise ActiveRecord::RecordNotFound
        end
      end
    end
  end
end
