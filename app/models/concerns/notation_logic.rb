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

    piece = game_pieces.detect { |piece| piece.startIndex == start_index }
    piece.hasMoved = true
    piece = do_move_two(position, piece) if piece.pieceType == 'pawn'
    game_pieces = castle(position, piece, game_pieces) if piece.pieceType == 'king'
    game_pieces = capture_piece(position, piece, game_pieces)
    piece.currentPosition = position
    piece.pieceType = piece_type

    self.pieces = game_pieces
    Move.new(piece.attributes)
  end

  def capture_piece(position, piece, game_pieces)
    remove_piece = game_pieces.detect { |game_piece| game_piece.currentPosition == position }
    remove_piece = do_en_passant(position, piece, game_pieces) if can_do_en_passant?(position, piece, game_pieces)

    game_pieces = game_pieces.reject { |game_piece| game_piece.startIndex == remove_piece.startIndex } if remove_piece.present?
    game_pieces
  end

  def can_do_en_passant?(position, piece, game_pieces)
    [
      piece.pieceType == 'pawn',
      piece.currentPosition[0] != position[0],
      game_pieces.detect { |game_piece| game_piece.currentPosition == position }.blank?
    ].all?
  end

  def do_en_passant(position, piece, game_pieces)
    captured_position = position[0] + piece.currentPosition[1]
    game_pieces.detect do |game_piece|
      game_piece.currentPosition == captured_position
    end
  end

  def do_move_two(next_move, piece)
    piece.movedTwo = true if (next_move[1].to_i - piece.currentPosition[1].to_i).abs == 2
    piece
  end

  def castle(position, piece, game_pieces)
    column_difference = piece.currentPosition[0].ord - position[0].ord
    row = piece.color == 'white' ? '1' : '8'

    if column_difference == -2
      game_pieces = game_pieces.map do |game_piece|
        if game_piece.currentPosition == ('h' + row)
          game_piece.currentPosition = 'f' + row
        end
        game_piece
      end
    end

    if column_difference == 2
      game_pieces = game_pieces.map do |game_piece|
        if game_piece.currentPosition == ('a' + row)
          game_piece.currentPosition = 'd' + row
        end
        game_piece
      end
    end

    game_pieces
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
    moves.length.even? ? 'white' : 'black'
  end

  def retrieve_start_index(notation, game_pieces)
    start_position = find_start_position(notation)
    piece_type = piece_type_from_notation(notation)

    if piece_type == 'king'
      game_pieces.detect do |piece|
        piece.pieceType == piece_type && piece.color == current_turn
      end.startIndex
    elsif start_position.length == 2
      game_pieces.detect { |piece| piece.currentPosition == start_position }.startIndex
    elsif start_position.length == 1
      value_from_column(notation, piece_type, start_position, game_pieces)
    elsif start_position.empty?
      piece_type = 'pawn' if notation.include?('=')
      value_from_moves(notation, piece_type, game_pieces)
    end
  end

  def find_start_position(notation)
    notation.gsub(position_from_notation(notation), '').chars.reject do |char|
      ['#', '=', 'x', char.capitalize].include?(char)
    end.join('')
  end

  def previously_moved_piece(notation, piece_type, game_pieces)
    game_pieces.detect do |piece|
      [
        piece.hasMoved.present?,
        piece.pieceType == piece_type,
        piece.color == current_turn,
        piece.valid_moves.include?(position_from_notation(notation))
      ].all?
    end
  end

  def value_from_column(notation, piece_type, start_position, game_pieces)
    game_piece = game_pieces.select do |piece|
      [
        piece.currentPosition[0] == start_position,
        piece.pieceType == piece_type,
        piece.color == current_turn,
        piece.valid_moves.include?(position_from_notation(notation))
      ].all?
    end
    if game_piece.size > 1 || game_piece.empty?
      puts notation
      puts piece_type
      puts start_position
      binding.pry
    end

    game_piece.first.startIndex
  end

  def value_from_moves(notation, piece_type, game_pieces)
    if previously_moved_piece(notation, piece_type, game_pieces).present?
      previously_moved_piece(notation, piece_type, game_pieces).startIndex
    else
      game_piece = game_pieces.select do |piece|
        [
          piece.hasMoved.blank?,
          piece.pieceType == piece_type,
          piece.color == current_turn,
          piece.valid_moves.include?(position_from_notation(notation))
        ].all?
      end

      if game_piece.size > 1 || game_piece.empty?
        puts notation
        puts piece_type
        binding.pry
      end

      game_piece.first.startIndex
    end
  end
end
