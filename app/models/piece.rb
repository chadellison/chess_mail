class Piece < ApplicationRecord
  validates_presence_of :currentPosition, :color, :pieceType, :startIndex

  has_many :game_pieces
  has_many :games, through: :game_pieces

  include PieceMoveLogic

  def serialize_piece
    {
      type: 'piece',
      id: id,
      attributes: {
        color: color,
        currentPosition: currentPosition,
        pieceType: pieceType,
        startIndex: startIndex,
        movedTwo: movedTwo,
        hasMoved: hasMoved
      }
    }
  end
end
