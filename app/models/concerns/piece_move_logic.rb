module PieceMoveLogic
  extend ActiveSupport::Concern

  LETTER_KEY = { 'a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5, 'f' => 6, 'g' => 7, 'h' => 8 }.freeze

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
      move[0] > currentPosition[0].next || move[0] < (currentPosition[0].ord - 1).chr ||
      move[1].to_i > currentPosition[1].to_i + 1 || move[1].to_i < currentPosition[1].to_i - 1
    end + [(currentPosition[0].ord - 2).chr + currentPosition[1], currentPosition[0].next.next + currentPosition[1]]
  end

  def moves_for_knight
    possible_moves = []

    possible_moves << (currentPosition[0].ord - 2).chr + (currentPosition[1].to_i + 1).to_s
    possible_moves << (currentPosition[0].ord - 2).chr + (currentPosition[1].to_i - 1).to_s

    possible_moves << (currentPosition[0].ord + 2).chr + (currentPosition[1].to_i + 1).to_s
    possible_moves << (currentPosition[0].ord + 2).chr + (currentPosition[1].to_i - 1).to_s

    possible_moves << (currentPosition[0].ord - 1).chr + (currentPosition[1].to_i + 2).to_s
    possible_moves << (currentPosition[0].ord - 1).chr + (currentPosition[1].to_i - 2).to_s

    possible_moves << currentPosition[0].next + (currentPosition[1].to_i + 2).to_s
    possible_moves << currentPosition[0].next + (currentPosition[1].to_i - 2).to_s

    remove_out_of_bounds_moves(possible_moves)
  end

  def moves_for_pawn
    left_letter = (currentPosition[0].ord - 1).chr
    right_letter = (currentPosition[0].ord + 1).chr
    up_count = currentPosition[1].to_i + 1
    down_count = currentPosition[1].to_i - 1

    possible_moves = moves_up(up_count + 1) +
    moves_down((down_count - 1).abs) +
      [
        moves_left(left_letter).last[0] + moves_up(up_count).last[1],
        moves_right(right_letter).last[0] + moves_up(up_count).last[1],
        moves_left(left_letter).last[0] + moves_down(down_count).last[1],
        moves_right(right_letter).last[0] + moves_down(down_count).last[1],
      ]
    remove_out_of_bounds_moves(possible_moves)
  end

  def remove_out_of_bounds_moves(moves)
    moves.reject do |move|
      move[0] < 'a' || move[0] > 'h' || move[1..-1].to_i < 1 || move[1..-1].to_i > 8
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
    destination_piece = game_pieces.find_by(currentPosition: destination)

    if destination_piece.present?
      destination_piece.color != color
    else
      true
    end
  end

  def vertical_collision?(destination, occupied_spaces)
    difference = (currentPosition[1].to_i - destination[1].to_i).abs - 1

    if currentPosition[1].to_i > destination[1].to_i
      (moves_down((difference - currentPosition[1].to_i).abs) & occupied_spaces).present?
    else
      (moves_up(difference + currentPosition[1].to_i) & occupied_spaces).present?
    end
  end

  def horizontal_collision?(destination, occupied_spaces)
    if currentPosition[0] > destination[0]
      (moves_left(destination[0]) & occupied_spaces).present?
    else
      (moves_right(destination[0]) & occupied_spaces).present?
    end
  end

  def diagonal_collision?(destination, occupied_spaces)
    if currentPosition[0] < destination[0]
      horizontal_moves = moves_right(destination[0])
    else
      horizontal_moves = moves_left(destination[0])
    end

    difference = (currentPosition[1].to_i - destination[1].to_i).abs - 1
    if currentPosition[1] < destination[1]
      vertical_moves = moves_up(difference + currentPosition[1].to_i)
    else
      vertical_moves = moves_down((difference - currentPosition[1].to_i).abs)
    end
    (extract_diagonals(horizontal_moves.zip(vertical_moves)) & occupied_spaces).present?
  end

  def king_is_safe?(color, game_pieces)
    king = game_pieces.find_by(pieceType: 'king', color: color)
    game_pieces.none? do |game_piece|
      game_piece.moves_for_piece.include?(king.currentPosition) &&
        game_piece.valid_move_path?(king.currentPosition, game_pieces.pluck(:currentPosition)) &&
        game_piece.valid_destination?(king.currentPosition, game_pieces)
    end
  end
end
