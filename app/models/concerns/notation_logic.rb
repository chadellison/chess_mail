module NotationLogic
  extend ActiveSupport::Concern

  PIECE_TYPE = {
    'N' => 'knight', 'B' => 'bishop', 'R' => 'rook', 'Q' => 'queen',
    'K' => 'king', 'O' => 'king'
  }.freeze

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
    elsif notation[-1] == '#'
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
    pieces.count.even? ? 'white' : 'black'
  end

  def retrieve_start_index(notation)
    current_location = find_current_location(notation)

    piece_type = piece_type_from_notation(notation)

    if current_location.length == 2
      previously_moved = pieces.order(created_at: :desc)
                               .find_by(currentPosition: current_location)
      if previously_moved.present?
        previously_moved.startIndex
      else
        START_INDICES[current_location]
      end
    elsif current_location.length == 1
      if START_INDICES[piece_type][current_location].present?
        START_INDICES[piece_type][current_location][current_turn]
      else
        pieces.where(pieceType: piece_type)
              .all.detect do |piece|
                piece.currentPosition[0] == current_location
              end.startIndex
      end
    elsif piece_type == 'king' || piece_type == 'queen'
      START_INDICES[piece_type][current_turn]
    elsif current_location.empty?
      # previously_moved = pieces.where(pieceType: piece_type, color: current_turn)
      #                          .detect do |piece|
      #                            piece.possible_moves(pieces) == position_from_notation(notation)
      #                          end
      #
      # if previously_moved.present?
      #   previously_moved.startIndex
      # else
      #   # coords...
      #   START_INDICES[coordinates]
      # end

      notation
    end
  end

  def find_current_location(notation)
    notation.gsub(position_from_notation(notation), '').chars.reject do |char|
      ['#', '=', 'x', char.capitalize].include?(char)
    end.join('')
  end

  START_INDICES = {
    'a8' => 1,
    'b8' => 2,
    'c8' => 3,
    'd8' => 4,
    'e8' => 5,
    'f8' => 6,
    'g8' => 7,
    'h8' => 8,
    'a7' => 9,
    'b7' => 10,
    'c7' => 11,
    'd7' => 12,
    'e7' => 13,
    'f7' => 14,
    'g7' => 15,
    'h7' => 16,
    'a2' => 17,
    'b2' => 18,
    'c2' => 19,
    'd2' => 20,
    'e2' => 21,
    'f2' => 22,
    'g2' => 23,
    'h2' => 24,
    'a1' => 25,
    'b1' => 26,
    'c1' => 27,
    'd1' => 28,
    'e1' => 29,
    'f1' => 30,
    'g1' => 31,
    'h1' => 32,
    'king' => {
      'black' => 5,
      'white' => 29
    },
    'queen' => {
      'black' => 4,
      'white' => 28
    },
    'rook' => {
      'a' => {
        'black' => 1,
        'white' => 25
      },
      'h' => {
        'black' => 8,
        'white' => 32
      }
    },
    'bishop' => {
      'c' => {
        'black' => 3,
        'white' => 27
      },
      'f' => {
        'black' => 6,
        'white' => 30
      }
    },
    'knight' => {
      'b' => {
        'black' => 2,
        'white' => 26
      },
      'g' => {
        'black' => 7,
        'white' => 31
      }
    },
    'pawn' => {
      'a' => {
        'black' => 9,
        'white' => 17
      },
      'b' => {
        'black' => 10,
        'white' => 18
      },
      'c' => {
        'black' => 11,
        'white' => 19
      },
      'd' => {
        'black' => 12,
        'white' => 20
      },
      'e' => {
        'black' => 13,
        'white' => 21
      },
      'f' => {
        'black' => 14,
        'white' => 22
      },
      'g' => {
        'black' => 15,
        'white' => 23
      },
      'h' => {
        'black' => 16,
        'white' => 24
      }
    }
  }.freeze
end
