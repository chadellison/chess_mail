module Api
  module V1
    class AnalyticsController < Api::V1::BaseController
      respond_to :json

      def index
        render json: Analysis.serialize(JSON.parse(move_params[:moves]))
      end

      private

      def move_params
        params.permit(:moves)
      end
    end
  end
end
