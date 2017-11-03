class Analysis
  class << self
    def move_signature(moves)
      moves.map { |move| " #{move['startIndex']}:#{move['currentPosition']}" }.join
    end

    def serialize(moves)
      signature = move_signature(moves)
      {
        data: {
          type: 'move_signature',
          attributes: {
            white: Game.similar_games(signature).winning_games('white').count,
            black: Game.similar_games(signature).winning_games('black').count,
            draw: Game.similar_games(signature).drawn_games.count
          }
        }
      }
    end
  end
end
