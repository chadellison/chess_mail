module NotationLogic
  extend ActiveSupport::Concern

  def piece_type_from_notation(notation)
    piece_type = 'pawn' if notation.length == 2
    piece_type = 'knight' if notation[0] == 'N'
    piece_type = 'bishop' if notation[0] == 'B'
    piece_type = 'rook' if notation[0] == 'R'
    piece_type = 'queen' if notation[0] == 'Q'
    piece_type = 'king' if notation[0] == 'K'
    piece_type = 'king' if notation[0] == 'O'
    piece_type
  end

  def create_piece_from_notation(notation)
    pieces.create(
      currentPosition: position_from_notation(notation),
      pieceType: piece_type_from_notation(notation),
      color: current_turn
    )
  end

  def position_from_notation(notation)
    if notation[0] == 'O'
      column = notation == 'O-O' ? 'g' : 'c'
      row = current_turn == 'white' ? '1' : '8'
      column + row
    else
      notation[-2..-1]
    end
  end
end
