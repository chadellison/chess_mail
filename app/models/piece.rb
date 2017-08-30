class Piece < ApplicationRecord
  has_many :game_pieces
  has_many :games, through: :game_pieces
end
