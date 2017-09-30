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
    moves_for_piece.select { |move| valid_move?(move) }
  end

  def valid_move?(move)
    valid_move_path?(move, game.pieces.pluck(:currentPosition)) &&
      valid_destination?(move, game.pieces) &&
      valid_for_piece?(move, game.pieces) &&
      king_is_safe?(color, pieces_with_next_move(move))
  end

  def handle_moved_two(next_move)
    if (next_move[1].to_i - currentPosition[1].to_i).abs == 2
      update(movedTwo: true)
    else
      update(movedTwo: false)
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
