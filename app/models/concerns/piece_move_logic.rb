module PieceMoveLogic
  extend ActiveSupport::Concern

  def moves_for_rook
    moves_up +
      moves_down +
      moves_left +
      moves_right
  end

  def moves_for_bishop
    top_right = extract_diagonals(moves_right.zip(moves_up))
    top_left = extract_diagonals(moves_left.zip(moves_up))
    bottom_left = extract_diagonals(moves_left.zip(moves_down))
    bottom_right = extract_diagonals(moves_right.zip(moves_down))

    top_right + top_left + bottom_left + bottom_right
  end

  def moves_for_queen
    moves_for_rook + moves_for_bishop
  end

  def moves_for_king
    moves_for_queen.reject do |move|
      move[0] > currentPosition[0].next ||
        move[0] < (currentPosition[0].ord - 1).chr ||
        move[1].to_i > currentPosition[1].to_i + 1 ||
        move[1].to_i < currentPosition[1].to_i - 1
    end + [(currentPosition[0].ord - 2).chr + currentPosition[1],
           currentPosition[0].next.next + currentPosition[1]]
  end

  def moves_for_knight
    moves = []
    column = currentPosition[0].ord
    row = currentPosition[1].to_i

    moves << (column - 2).chr + (row + 1).to_s
    moves << (column - 2).chr + (row - 1).to_s

    moves << (column + 2).chr + (row + 1).to_s
    moves << (column + 2).chr + (row - 1).to_s

    moves << (column - 1).chr + (row + 2).to_s
    moves << (column - 1).chr + (row - 2).to_s

    moves << (column + 1).chr + (row + 2).to_s
    moves << (column + 1).chr + (row - 2).to_s

    remove_out_of_bounds_moves(moves)
  end

  def moves_for_pawn
    left_letter = (currentPosition[0].ord - 1).chr
    right_letter = (currentPosition[0].ord + 1).chr
    up_count = currentPosition[1].to_i + 1
    down_count = currentPosition[1].to_i - 1

    possible_moves = moves_up(up_count + 1) +
    moves_down((down_count - 1).abs) + [
      moves_left(left_letter).last[0] +
      moves_up(up_count).last[1],
      moves_right(right_letter).last[0] + moves_up(up_count).last[1],
      moves_left(left_letter).last[0] + moves_down(down_count).last[1],
      moves_right(right_letter).last[0] + moves_down(down_count).last[1]
    ]
    remove_out_of_bounds_moves(possible_moves)
  end

  def remove_out_of_bounds_moves(moves)
    moves.reject do |move|
      move[0] < 'a' ||
        move[0] > 'h' ||
        move[1..-1].to_i < 1 ||
        move[1..-1].to_i > 8
    end
  end

  def extract_diagonals(moves)
    moves.map do |move_pair|
      (move_pair[0][0] + move_pair[1][1]) unless move_pair.include?(nil)
    end.compact
  end

  def moves_up(count = 8)
    possible_moves = []
    row = currentPosition[1].to_i

    while row < count
      row += 1
      possible_moves << (currentPosition[0] + row.to_s)
    end
    possible_moves
  end

  def moves_down(count = 1)
    possible_moves = []
    row = currentPosition[1].to_i

    while row > count
      row -= 1
      possible_moves << (currentPosition[0] + row.to_s)
    end
    possible_moves
  end

  def moves_left(letter = 'a')
    possible_moves = []
    column = currentPosition[0]

    while column > letter
      column = (column.ord - 1).chr

      possible_moves << (column + currentPosition[1])
    end
    possible_moves
  end

  def moves_right(letter = 'h')
    possible_moves = []
    column = currentPosition[0]

    while column < letter
      column = column.next

      possible_moves << (column + currentPosition[1])
    end
    possible_moves
  end

  def valid_move_path?(destination, occupied_spaces)
    if ['king', 'knight'].include?(pieceType)
      true
    elsif currentPosition[0] == destination[0]
      !vertical_collision?(destination, occupied_spaces)
    elsif currentPosition[1] == destination[1]
      !horizontal_collision?(destination, occupied_spaces)
    else
      !diagonal_collision?(destination, occupied_spaces)
    end
  end

  def valid_destination?(destination, game_pieces)
    game_pieces.reload unless game_pieces.class == Array
    destination_piece = game_pieces.to_a.detect { |piece| piece.currentPosition == destination }

    if destination_piece.present?
      destination_piece.color != color
    else
      true
    end
  end

  def vertical_collision?(destination, occupied_spaces)
    row = currentPosition[1].to_i
    difference = (row - destination[1].to_i).abs - 1

    if row > destination[1].to_i
      (moves_down((difference - row).abs) & occupied_spaces).present?
    else
      (moves_up(difference + row) & occupied_spaces).present?
    end
  end

  def horizontal_collision?(destination, occupied_spaces)
    if currentPosition[0] > destination[0]
      (moves_left((destination[0].ord + 1).chr) & occupied_spaces).present?
    else
      (moves_right((destination[0].ord - 1).chr) & occupied_spaces).present?
    end
  end

  def diagonal_collision?(destination, occupied_spaces)
    if currentPosition[0] < destination[0]
      horizontal_moves = moves_right((destination[0].ord - 1).chr)
    else
      horizontal_moves = moves_left((destination[0].ord + 1).chr)
    end

    difference = (currentPosition[1].to_i - destination[1].to_i).abs - 1
    if currentPosition[1] < destination[1]
      vertical_moves = moves_up(difference + currentPosition[1].to_i)
    else
      vertical_moves = moves_down((difference - currentPosition[1].to_i).abs)
    end
    (extract_diagonals(horizontal_moves.zip(vertical_moves)) & occupied_spaces)
      .present?
  end

  def king_is_safe?(allied_color, game_pieces)
    king = game_pieces.detect do |game_piece|
      game_piece.pieceType == 'king' && game_piece.color == allied_color
    end

    return false if king.nil?
    
    occupied_spaces = game_pieces.map(&:currentPosition)
    opponent_pieces = game_pieces.reject { |game_piece| game_piece.color == allied_color }
    opponent_pieces.none? do |game_piece|
      game_piece.moves_for_piece.include?(king.currentPosition) &&
        game_piece.valid_move_path?(king.currentPosition, occupied_spaces) &&
        game_piece.valid_destination?(king.currentPosition, game_pieces) &&
        game_piece.valid_for_piece?(king.currentPosition, game_pieces)
    end
  end

  def pieces_with_next_move(move)
    game.pieces.reject { |game_piece| game_piece.currentPosition == move }
        .map do |game_piece|
          if game_piece.startIndex == startIndex
            updated_piece = Piece.new(game_piece.attributes)
            updated_piece.currentPosition = move
            updated_piece
          else
            game_piece
          end
        end
  end

  def valid_for_piece?(next_move, game_pieces)
    return castle?(next_move, game_pieces) if king_moved_two?(next_move)
    return valid_for_pawn?(next_move, game_pieces) if pieceType == 'pawn'
    true
  end

  def king_moved_two?(next_move)
    pieceType == 'king' && (currentPosition[0].ord - next_move[0].ord).abs == 2
  end

  def castle?(next_move, game_pieces)
    column = next_move[0] == 'c' ? 'a' : 'h'
    rook = game_pieces.find_by(currentPosition: (column + next_move[1]))

    if next_move[0] == 'c'
      through_check_moves = pieces_with_next_move('d' + next_move[1])
    else
      through_check_moves = pieces_with_next_move('f' + next_move[1])
    end

    [rook.present? && rook.hasMoved.blank?, hasMoved.blank?,
      king_is_safe?(color, game.pieces),
      king_is_safe?(color, through_check_moves)
    ].all?
  end

  def valid_for_pawn?(next_move, game_pieces)
    if next_move[0] == currentPosition[0]
      advance_pawn?(next_move, game_pieces)
    else
      capture?(next_move, game_pieces)
    end
  end

  def capture?(next_move, game_pieces)
    [
      next_move[0].ord == currentPosition[0].ord + 1 || next_move[0].ord == currentPosition[0].ord - 1,
      next_move == next_move[0] + advance_pawn_row(1),
      !empty_square?(next_move, game_pieces) || can_en_pessant?(next_move, game_pieces)
    ].all?
  end

  def can_en_pessant?(next_move, game_pieces)
    game_pieces.any? do |game_piece|
      game_piece.currentPosition == (next_move[0] + currentPosition[1]) &&
      game_piece.movedTwo?
    end
  end

  def empty_square?(space, game_pieces)
    game_pieces.detect do |game_piece|
      game_piece.currentPosition == space
    end.blank?
  end

  def move_two?(next_move, game_pieces)
    empty_square?(next_move[0] + advance_pawn_row(1), game_pieces) &&
    empty_square?(next_move[0] + advance_pawn_row(2), game_pieces) &&
    hasMoved.blank?
  end

  def advance_pawn_row(amount)
    if color == 'white'
      (currentPosition[1].to_i + amount).to_s
    else
      (currentPosition[1].to_i - amount).to_s
    end
  end

  def advance_pawn?(next_move, game_pieces)
    if next_move[1].to_i == currentPosition[1].to_i + 2 || next_move[1].to_i == currentPosition[1].to_i - 2
      move_two?(next_move, game_pieces)
    else
      advance_pawn_row(1) == next_move[1] && empty_square?(next_move, game_pieces)
    end
  end
end
