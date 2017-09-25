class MoveLogic
  class << self
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
      end + [(position[0].ord - 2).chr + position[1], position[0].next.next + position[1]]
    end

    def moves_for_knight(position)
      possible_moves = []

      possible_moves << (position[0].ord - 2).chr + (position[1].to_i + 1).to_s
      possible_moves << (position[0].ord - 2).chr + (position[1].to_i - 1).to_s

      possible_moves << (position[0].ord + 2).chr + (position[1].to_i + 1).to_s
      possible_moves << (position[0].ord + 2).chr + (position[1].to_i - 1).to_s

      possible_moves << (position[0].ord - 1).chr + (position[1].to_i + 2).to_s
      possible_moves << (position[0].ord - 1).chr + (position[1].to_i - 2).to_s

      possible_moves << position[0].next + (position[1].to_i + 2).to_s
      possible_moves << position[0].next + (position[1].to_i - 2).to_s

      remove_out_of_bounds_moves(possible_moves)
    end

    def moves_for_pawn(position)
      left_letter = (position[0].ord - 1).chr
      right_letter = (position[0].ord + 1).chr
      up_count = position[1].to_i + 1
      down_count = position[1].to_i - 1

      moves_up(position, up_count + 1) +
      moves_down(position, down_count - 1).concat(
        [
          moves_left(position, left_letter).last[0] + moves_up(position, up_count).last[1],
          moves_right(position, right_letter).last[0] + moves_up(position, up_count).last[1],
          moves_left(position, left_letter).last[0] + moves_down(position, down_count).last[1],
          moves_right(position, right_letter).last[0] + moves_down(position, down_count).last[1],
        ]
      )
    end

    def remove_out_of_bounds_moves(moves)
      moves.reject do |move|
        move[0] < 'a' || move[0] > 'h' || move[1] < '1' || move[1] > '8'
      end
    end

    def extract_diagonals(moves)
      moves.map do |move_pair|
        (move_pair[0][0] + move_pair[1][1]) unless move_pair.include?(nil)
      end.compact
    end

    def moves_up(position, count = 8)
      possible_moves = []
      row = position[1].to_i

      while row < count
        row += 1
        possible_moves << (position[0] + row.to_s)
      end
      possible_moves
    end

    def moves_down(position, count = 1)
      possible_moves = []
      row = position[1].to_i

      while row > count
        row -= 1
        possible_moves << (position[0] + row.to_s)
      end
      possible_moves
    end

    def moves_left(position, letter = 'a')
      possible_moves = []
      column = position[0]

      while column > letter
        column = (column.ord - 1).chr

        possible_moves << (column + position[1])
      end
      possible_moves
    end

    def moves_right(position, letter = 'h')
      possible_moves = []
      column = position[0]

      while column < letter
        column = column.next

        possible_moves << (column + position[1])
      end
      possible_moves
    end
  end
end
