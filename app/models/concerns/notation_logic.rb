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
      value_from_start_indices(notation, piece_type, start_position)
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

  def value_from_start_indices(notation, piece_type, start_position)
    if previously_moved_piece(notation, piece_type).present?
      previously_moved_piece(notation, piece_type).startIndex
    else
      START_INDICES[piece_type][start_position][current_turn]
    end
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
