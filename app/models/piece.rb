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
    [
      valid_move_path?(move, game.pieces.reload.map(&:currentPosition)),
      valid_destination?(move, game.reload.pieces),
      valid_for_piece?(move, game.reload.pieces),
      king_is_safe?(color, pieces_with_next_move(move))
    ].all?
  end

  def handle_moved_two(next_move)
    game.pieces.where(pieceType: 'pawn').update_all(movedTwo: false)

    if (next_move[1].to_i - currentPosition[1].to_i).abs == 2 && pieceType == 'pawn'
      update(movedTwo: true)
    end
  end
end
