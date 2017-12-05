class MoveRank < ApplicationRecord
  has_many :move_rank_games
  has_many :games, through: :move_rank_games

  validates_uniqueness_of :position_signature

  def find_start_index(move_count)
    position_signature[moves_count].split('.').first
  end
end
