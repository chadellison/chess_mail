class Piece < ApplicationRecord
  validates_presence_of :currentPosition, :color, :pieceType, :startIndex

  has_many :game_pieces
  has_many :games, through: :game_pieces

  include PieceMoveLogic

  def moves_for_piece
    case pieceType
    when 'rook'
      moves_for_rook
    when 'biship'
      moves_for_bishop
    when 'queen'
      moves_for_queen
    when 'king'
      moves_for_king
    when 'knight'
      moves_for_knight
    when 'pawn'
      moves_for_pawn
    end
  end

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
