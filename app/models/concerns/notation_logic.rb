module NotationLogic
  extend ActiveSupport::Concern

  PIECE_TYPE = {
    'N' => 'knight', 'B' => 'bishop', 'R' => 'rook', 'Q' => 'queen',
    'K' => 'king', 'O' => 'king'
  }.freeze

  def create_move_from_notation(notation)
    position = position_from_notation(notation)
    start_index = retrieve_start_index(notation)
    piece_type = piece_type_from_notation(notation)

    move(currentPosition: position, startIndex: start_index, pieceType: piece_type)
  end

  def position_from_notation(notation)
    if notation[0] == 'O'
      column = notation == 'O-O' ? 'g' : 'c'
      row = current_turn == 'white' ? '1' : '8'
      column + row
    elsif notation[-1] == '#' || notation[-2..-1] == '++'
      notation[-3..-2]
    elsif notation[-2] == '='
      notation[-4..-3]
    else
      notation[-2..-1]
    end
  end

  def piece_type_from_notation(notation)
    if notation.gsub(/[^a-z\s]/i, '').chars.none? { |char| char.capitalize == char }
      'pawn'
    elsif notation.include?('=')
      PIECE_TYPE[notation[-1]]
    else
      PIECE_TYPE[notation[0]]
    end
  end

  def current_turn
    moves.count.even? ? 'white' : 'black'
  end

  def retrieve_start_index(notation)
    start_position = find_start_position(notation)
    piece_type = piece_type_from_notation(notation)

    if piece_type == 'king'
      pieces.find_by(pieceType: piece_type, color: current_turn).startIndex
    elsif start_position.length == 2
      pieces.find_by(currentPosition: start_position).startIndex
    elsif start_position.length == 1
      value_from_column(notation, piece_type, start_position)
    elsif start_position.empty?
      piece_type = 'pawn' if notation.include?('=')
      value_from_moves(notation, piece_type)
    end
  end

  def find_start_position(notation)
    notation.gsub(position_from_notation(notation), '').chars.reject do |char|
      ['#', '=', 'x', char.capitalize].include?(char)
    end.join('')
  end

  def previously_moved_piece(notation, piece_type)
    pieces.where(
      hasMoved: true,
      pieceType: piece_type,
      color: current_turn
    ).detect { |piece| piece.valid_moves.include?(position_from_notation(notation)) }
  end

  def value_from_column(notation, piece_type, start_position)
    pieces.detect do |piece|
      piece.currentPosition[0] == find_start_position(notation) &&
      piece.pieceType == piece_type &&
      piece.color == current_turn &&
      piece.valid_moves.include?(position_from_notation(notation))
    end.startIndex
  end

  def value_from_moves(notation, piece_type)
    if previously_moved_piece(notation, piece_type).present?
      previously_moved_piece(notation, piece_type).startIndex
    else
      pieces.where(hasMoved: false, pieceType: piece_type, color: current_turn)
            .detect do |piece|
              piece.valid_moves.include?(position_from_notation(notation))
            end.startIndex
    end
  end
end
