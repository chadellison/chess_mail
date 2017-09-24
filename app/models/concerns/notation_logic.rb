module NotationLogic
  extend ActiveSupport::Concern

  PIECE_TYPE = {
    'N' => 'knight', 'B' => 'bishop', 'R' => 'rook', 'Q' => 'queen',
    'K' => 'king', 'O' => 'king'
  }

  def create_piece_from_notation(notation)
    pieces.create(
      currentPosition: position_from_notation(notation),
      pieceType: piece_type_from_notation(notation),
      color: current_turn,
      startIndex: retrieve_start_index(notation)
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

  def piece_type_from_notation(notation)
    if notation.length == 2
      'pawn'
    else
      PIECE_TYPE[notation[0]]
    end
  end

  def current_turn
    pieces.count.even? ? 'white' : 'black'
  end

  def retrieve_start_index(notation)
    # find piece that has relevant row and or column in game and get its startIndex
    # find piece on new board by row or column and get its initial startIndex
    notation
  end
end
