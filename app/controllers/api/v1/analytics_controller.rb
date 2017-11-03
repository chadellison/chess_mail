module Api
  module V1
    class AnalyticsController < Api::V1::BaseController
      respond_to :json

      def index
        move_signature = JSON.parse(move_params[:moves]).map do |move| " #{move['startIndex']}:#{move['currentPosition']}" end.join
        serialized_game_analysis = {
          data: {
            type: 'move_signature',
            attributes: {
              white: Game.similar_games(move_signature).winning_games('white').count,
              black: Game.similar_games(move_signature).winning_games('black').count,
              draw: Game.similar_games(move_signature).drawn_games.count
            }
          }
        }
        render json: serialized_game_analysis
      end

      private

      def move_params
        params.permit(:moves)
      end
    end
  end
end
