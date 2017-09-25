class MoveLogic
  class << self

    LETTER_KEY = ['a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5, 'f' => 6, 'g' => 7, 'h' => 8]

    def moves_for_rook(position)
      moves_up(position) +
        moves_down(position) +
        moves_left(position) +
        moves_right(position)
    end

    def moves_for_bishop(position)
      top_right = extract_diagonals(moves_right(position).zip(moves_up(position)))
      top_left = extract_diagonals(moves_left(position).zip(moves_up(position)))
      bottom_left = extract_diagonals(moves_left(position).zip(moves_down(position)))
      bottom_right = extract_diagonals(moves_right(position).zip(moves_down(position)))

      top_right + top_left + bottom_left + bottom_right
    end

    def moves_for_queen(position)
      moves_for_rook(position) + moves_for_bishop(position)
    end

    def moves_for_king(position)
      moves_for_queen(position).reject do |move|
        move[0] > position[0].next || move[0] < (position[0].ord - 1).chr ||
        move[1].to_i > position[1].to_i + 1 || move[1].to_i < position[1].to_i - 1
      end
    end

    def extract_diagonals(moves)
      moves.map do |move_pair|
        (move_pair[0][0] + move_pair[1][1]) unless move_pair.include?(nil)
      end.compact
    end

    def moves_up(position)
      possible_moves = []
      row = position[1].to_i

      while row < 8
        row += 1
        possible_moves << (position[0] + row.to_s)
      end
      possible_moves
    end

    def moves_down(position)
      possible_moves = []
      row = position[1].to_i

      while row > 1
        row -= 1
        possible_moves << (position[0] + row.to_s)
      end
      possible_moves
    end

    def moves_left(position)
      possible_moves = []
      column = position[0]

      while column > 'a'
        column = (column.ord - 1).chr

        possible_moves << (column + position[1])
      end
      possible_moves
    end

    def moves_right(position)
      possible_moves = []
      column = position[0]

      while column < 'h'
        column = column.next

        possible_moves << (column + position[1])
      end
      possible_moves
    end
  end
end
