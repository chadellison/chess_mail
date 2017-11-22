class AnalyticsSerializer
  class << self
    def serialize(signature)
      {
        data: {
          type: 'move_signature',
          attributes: {
            whiteWins: Game.similar_games(signature).winning_games(1, 'white').count,
            blackWins: Game.similar_games(signature).winning_games(-1, 'black').count,
            draws: Game.similar_games(signature).drawn_games.count
          }
        }
      }
    end
  end
end
