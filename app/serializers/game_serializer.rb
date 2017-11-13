class GameSerializer
  class << self
  #   def serialize_games(games, user_email)
  #     {
  #       data: games.map { |game| game.serialize_game(user_email) },
  #       meta: { count: games.count }
  #     }
  #   end
  # end

    def serialize(game, user_email)
      opponent_email = game.current_opponent_email(user_email).downcase.strip
      opponent_gravatar = Digest::MD5.hexdigest(opponent_email)

      {
        type: 'game',
        id: game.id,
        attributes: {
          pending: game.pending,
          playerColor: game.current_player_color(user_email),
          opponentName: game.current_opponent_name(user_email),
          opponentGravatar: opponent_gravatar,
          isChallenger: game.challenger?(user_email),
          outcome: game.outcome,
          human: game.human,
          robot: game.robot
        },
        included: game.moves.order(:updated_at).map(&:serialize_move)
      }
    end
  end
end
