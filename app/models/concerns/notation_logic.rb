module NotationLogic
  extend ActiveSupport::Concern

  PIECE_TYPE = {
    'N' => 'knight', 'B' => 'bishop', 'R' => 'rook', 'Q' => 'queen',
    'K' => 'king', 'O' => 'king'
  }.freeze

  def create_piece_from_notation(notation)
    pieces.find_by(startIndex: retrieve_start_index(notation)).update(
      currentPosition: position_from_notation(notation),
      pieceType: piece_type_from_notation(notation),
      color: current_turn
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
    moves.count.even? ? 'white' : 'black'
  end

  def retrieve_start_index(notation)
    start_position = find_start_position(notation)

    piece_type = piece_type_from_notation(notation)

    if piece_type == 'king' || piece_type == 'queen'
      pieces.find_by(pieceType: piece_type, color: current_turn).startIndex
    elsif start_position.length == 2
      previously_moved = pieces.where(hasMoved: true, color: current_turn)
                               .order(updated_at: :desc)
                               .find_by(currentPosition: start_position)
      if previously_moved.present?
        previously_moved.startIndex
      else
        json_pieces = File.read(Rails.root + './json/pieces.json')
        JSON.parse(json_pieces)[start_position]['piece']['startIndex']
      end
    elsif start_position.length == 1
      previously_moved = pieces.where(
        hasMoved: true,
        pieceType: piece_type,
        color: current_turn
      ).all.detect { |piece| piece.currentPosition[0] == start_position }

      if previously_moved.present?
        previously_moved.startIndex
      else
        START_INDICES[piece_type][start_position][current_turn]
      end
    elsif start_position.empty?
      previously_moved = pieces.where(
        hasMoved: true,
        pieceType: piece_type,
        color: current_turn
      ).detect { |piece| piece.valid_moves.include?(position_from_notation) }

      if previously_moved.present?
        previously_moved.startIndex
      else
        pieces.where(hasMoved: false, pieceType: piece_type, color: current_turn)
              .detect { |piece| piece.valid_moves.include?(position_from_notation) }
              .startIndex
      end
    end
  end

  def find_start_position(notation)
    notation.gsub(position_from_notation(notation), '').chars.reject do |char|
      ['#', '=', 'x', char.capitalize].include?(char)
    end.join('')
  end

  START_INDICES = {
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
