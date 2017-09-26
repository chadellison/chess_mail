class Piece < ApplicationRecord
  validates_presence_of :currentPosition, :color, :pieceType, :startIndex

  belongs_to :game, optional: true

  include PieceMoveLogic

  def moves_for_piece
    case pieceType
    when 'rook'
      moves_for_rook
    when 'bishop'
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

  def valid_moves
  #   moves_for_piece.select do |move|
  #     valid_move_path() &&
  #       valid_destination &&
  #       king_is_safe(color, game.pieces) &&
  #       king_will_be_safe
  #   end
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
