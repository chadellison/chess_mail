class Game < ApplicationRecord
  has_many :user_games
  has_many :users, through: :user_games
  has_many :game_pieces
  has_many :pieces, through: :game_pieces

  class << self
    def serialize_games(games)
      { data: games.map(&:serialize_game), meta: { count: games.count } }
    end
  end

  def serialize_game
    {
      type: 'game',
      id: id,
      attributes: nil,
    }
  end
end
