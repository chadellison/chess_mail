module Api
  module V1
    class AnalyticsController < Api::V1::BaseController
      respond_to :json

      def analysis
        render json: AnalyticsSerializer.serialize(move_params[:moveSignature])
      end

      private

      def move_params
        params.require(:moves).permit(:moveSignature)
      end
    end
  end
end
