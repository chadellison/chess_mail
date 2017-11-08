module NotationLogic
  extend ActiveSupport::Concern

  PIECE_TYPE = {
    'N' => 'knight', 'B' => 'bishop', 'R' => 'rook', 'Q' => 'queen',
    'K' => 'king', 'O' => 'king'
  }.freeze

  def create_move_from_notation(notation, game_pieces)
    position = position_from_notation(notation)
    start_index = retrieve_start_index(notation, game_pieces)
    piece_type = piece_type_from_notation(notation)

    move(currentPosition: position, startIndex: start_index, pieceType: piece_type)
  end

  def position_from_notation(notation)
    stripped_notation = notation.chars.reject do |char|
      ['Q', 'N', 'R', 'B', '=', '#', '+'].include?(char)
    end.join

    if stripped_notation[0] == 'O'
      column = notation == 'O-O' ? 'g' : 'c'
      row = current_turn == 'white' ? '1' : '8'
      column + row
    else
      stripped_notation[-2..-1]
    end
  end

  def piece_type_from_notation(notation)
    if notation.gsub(/[^a-z\s]/i, '').chars.none? { |char| char.capitalize == char }
      'pawn'
    elsif notation.include?('=')
      PIECE_TYPE[notation.sub('#', '')[-1]]
    else
      PIECE_TYPE[notation[0]]
    end
  end

  def current_turn
    moves.count.even? ? 'white' : 'black'
  end

  def retrieve_start_index(notation, game_pieces)
    start_position = find_start_position(notation)
    piece_type = piece_type_from_notation(notation)
    piece_type = 'pawn' if notation.include?('=')

    if piece_type == 'king'
      game_pieces.find_by(pieceType: piece_type, color: current_turn).startIndex
    elsif start_position.length == 2
      game_pieces.find_by(currentPosition: start_position).startIndex
    elsif start_position.length == 1
      value_from_column(notation, piece_type, start_position, game_pieces)
    elsif start_position.empty?
      value_from_moves(notation, piece_type, game_pieces)
    end
  end

  def find_start_position(notation)
    notation.gsub(position_from_notation(notation), '').chars.reject do |char|
      ['#', '=', 'x', 'K', 'Q', 'B', 'R', 'N'].include?(char)
    end.join('')
  end

  def value_from_column(notation, piece_type, start_position, game_pieces)
    index = ('a'..'h').include?(start_position) ? 0 : 1

    game_pieces.where(pieceType: piece_type, color: current_turn).detect do |piece|
      piece.currentPosition[index] == start_position &&
        piece.valid_moves.include?(position_from_notation(notation))
    end.startIndex
  end

  def value_from_moves(notation, piece_type, game_pieces)
    game_pieces.where(pieceType: piece_type, color: current_turn).detect do |piece|
      piece.valid_moves.include?(position_from_notation(notation))
    end.startIndex
  end
end
