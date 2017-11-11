module NotationLogic
  extend ActiveSupport::Concern

  PIECE_TYPE = {
    'N' => 'knight', 'B' => 'bishop', 'R' => 'rook', 'Q' => 'queen',
    'K' => 'king', 'O' => 'king'
  }.freeze

  def create_move_from_notation(notation, game_pieces)
    {
      currentPosition: position_from_notation(notation),
      startIndex: retrieve_start_index(notation, game_pieces),
      pieceType: piece_type_from_notation(notation)
    }
  end

  def create_notation(move_params)
    piece = pieces.find_by(startIndex: move_params[:startIndex])

    if piece.king_moved_two?(move_params[:currentPosition])
      return move_params[:currentPosition][0] == 'c' ? 'O-O-O.' : '0-0.'
    end

    next_move = move_params[:currentPosition]
    piece_types = same_piece_types(piece, next_move)

    notation = PIECE_TYPE[piece.pieceType].to_s
    notation += start_notation(piece_types, piece, next_move) if piece_types.count > 1
    notation += capture_notation(next_move) if occupied_square?(next_move)
    notation += next_move
    notation += "#{next_move}=#{PIECE_TYPE[piece.pieceType]}" if upgraded_pawn?(move_params)
    # notation += '+' if piece.king_is_safe?(pieces_with_next_move(next_move), pieces)
    notation
  end

  def same_piece_types(piece, next_move)
    pieces.where(pieceType: piece.pieceType).select do |game_piece|
      game_piece.valid_move?(next_move) &&
        game_piece.color == current_turn
    end
  end

  def start_notation(same_piece_types, piece, next_move)
    start = next_move[0] if similar_pieces(0, same_piece_types, piece).count == 1
    start = next_move[1] if similar_pieces(1, same_piece_types, piece).count == 1 && start.blank?
    start = next_move if start.blank?
    start
  end

  def similar_pieces(index, same_piece_types, piece)
    same_piece_types.select do |game_piece|
      game_piece.currentPosition[index] == piece.currentPosition[index]
    end
  end

  def capture_notation(coordinates)
    'x' if occupied_square?(coordinates)
  end

  def upgraded_pawn?(move_params)
    moves.where(startIndex: move_params[:startIndex])
         .pluck(:pieceType)
         .any? { |type| type != move_params[:pieceType] }
  end

  def occupied_square?(coordinates)
    pieces.find_by(currentPosition: coordinates).present?
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
    move_signature.to_s.split('.').count.even? ? 'white' : 'black'
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
