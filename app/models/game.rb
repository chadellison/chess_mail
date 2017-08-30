class Game < ApplicationRecord
  has_many :user_games
  has_many :users, through: :user_games
  has_many :game_pieces
  has_many :pieces, through: :game_pieces

  class << self
    def serialize_games(games)
      { data: games, meta: { count: games.count } }
    end
  end
end
