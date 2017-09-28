require 'rails_helper'

RSpec.describe Piece, type: :model do
  it 'validates the presence of a currentPosition' do
    piece = Piece.new(
      color: 'black',
      pieceType: 'knight',
      startIndex: Faker::Number.number(2)
    )

    expect(piece.valid?).to be false
    piece.update(currentPosition: 'a3')
    expect(piece.valid?).to be true
  end

  it 'validates the presence of a color' do
    piece = Piece.new(
      currentPosition: 'a2',
      pieceType: 'knight',
      startIndex: Faker::Number.number(2)
    )

    expect(piece.valid?).to be false
    piece.update(color: 'black')
    expect(piece.valid?).to be true
  end

  it 'validates the presence of a pieceType' do
    piece = Piece.new(
      currentPosition: 'a2',
      startIndex: Faker::Number.number(2),
      color: 'black'
    )

    expect(piece.valid?).to be false
    piece.update(pieceType: 'knight')
    expect(piece.valid?).to be true
  end

  it 'validates the presence of a startIndex' do
    piece = Piece.new(
      currentPosition: 'a2',
      pieceType: 'rook',
      color: 'black'
    )

    expect(piece.valid?).to be false
    piece.update(startIndex: '2')
    expect(piece.valid?).to be true
  end

  it 'belongs to a game' do
    piece = Piece.new(
      currentPosition: 'a2',
      pieceType: 'knight',
      color: 'white',
      startIndex: Faker::Number.number(2)
    )
    game = Game.new
    game.pieces << piece

    expect(piece.game).to eq game
  end

  describe '#moves_up' do
    it 'returns an array of all possible moves up given a position' do
      position = 'f3'
      piece = Piece.new(
        currentPosition: position,
        pieceType: 'rook',
        color: 'black'
      )

      expected = ['f4', 'f5', 'f6', 'f7', 'f8']

      expect(piece.moves_up).to eq expected
    end
  end

  describe '#moves_down' do
    it 'returns an array of all possible moves down given a position' do
      position = 'f3'

      piece = Piece.new(
        currentPosition: position,
        pieceType: 'rook',
        color: 'black'
      )
      expected = ['f2', 'f1']

      expect(piece.moves_down).to eq expected
    end
  end

  describe '#moves_left' do
    it 'returns an array of all possible moves left given a position' do
      position = 'f3'

      piece = Piece.new(
        currentPosition: position,
        pieceType: 'rook',
        color: 'black'
      )
      expected = ['e3', 'd3', 'c3', 'b3', 'a3']

      expect(piece.moves_left).to eq expected
    end
  end

  describe '#moves_right' do
    it 'returns an array of all possible moves right given a position' do
      position = 'f3'
      piece = Piece.new(
        currentPosition: position,
        pieceType: 'rook',
        color: 'black'
      )
      expected = ['g3', 'h3']

      expect(piece.moves_right).to eq expected
    end
  end

  describe '#moves_for_rook' do
    it 'returns an array of all possible moves for a rook in a given position' do
      position = 'd4'
      piece = Piece.new(
        currentPosition: position,
        pieceType: 'rook',
        color: 'black'
      )
      expected = ['d5', 'd6', 'd7', 'd8', 'd3', 'd2', 'd1', 'c4', 'b4', 'a4',
                  'e4', 'f4', 'g4', 'h4']

      expect(piece.moves_for_rook).to eq expected
    end
  end

  describe '#moves_for_bishop' do
    it 'returns an array of all possible moves for a bishop in a given position' do
      position = 'd4'
      piece = Piece.new(
        currentPosition: position,
        pieceType: 'rook',
        color: 'black'
      )
      expected = ['e5', 'f6', 'g7', 'h8', 'c5', 'b6', 'a7', 'c3', 'b2', 'a1',
                  'e3', 'f2', 'g1']

      expect(piece.moves_for_bishop).to eq expected
    end
  end

  describe '#extract_diagonals' do
    it 'returns an array of each set\'s first coordinate\'s column and second corrdinate\'s row' do
      piece = Piece.new(
        currentPosition: 'a2',
        pieceType: 'rook',
        color: 'black'
      )
      expect(piece.extract_diagonals([['b2', 'a3']])).to eq ['b3']
    end
  end

  describe '#moves_for_queen' do
    it 'returns an array of all possible moves for a queen in a given position' do
      position = 'd4'
      piece = Piece.new(
        currentPosition: position,
        pieceType: 'rook',
        color: 'black'
      )
      expected = ['d5', 'd6', 'd7', 'd8', 'd3', 'd2', 'd1', 'c4', 'b4', 'a4',
                  'e4', 'f4', 'g4', 'h4', 'e5', 'f6', 'g7', 'h8', 'c5', 'b6',
                  'a7', 'c3', 'b2', 'a1', 'e3', 'f2', 'g1']

      expect(piece.moves_for_queen).to eq expected
    end
  end

  describe '#moves_for_king' do
    it 'returns an array of all possible moves for a king in a given position' do
      position = 'd4'
      piece = Piece.new(
        currentPosition: position,
        pieceType: 'rook',
        color: 'black'
      )
      expected = ['d5', 'd3', 'c4', 'e4', 'e5', 'c5', 'c3', 'e3', 'b4', 'f4']

      expect(piece.moves_for_king).to eq expected
    end
  end

  describe '#moves_for_knight' do
    it 'returns an array of all possible moves for a knight in a given position' do
      position = 'd4'
      piece = Piece.new(
        currentPosition: position,
        pieceType: 'rook',
        color: 'black'
      )
      expected = ['b5', 'b3', 'f5', 'f3', 'c6', 'c2', 'e6', 'e2']

      expect(piece.moves_for_knight).to eq expected
    end
  end

  describe '#moves_for_pawn' do
    it 'returns an array of all possible moves for a pawn (of either color) in a given position' do
      position = 'd4'
      piece = Piece.new(
        currentPosition: position,
        pieceType: 'rook',
        color: 'black'
      )
      expected = ['d5', 'd6', 'd3', 'd2', 'c5', 'e5', 'c3', 'e3']

      expect(piece.moves_for_pawn).to eq expected
    end
  end

  describe '#remove_out_of_bounds_moves' do
    xit 'returns an array of all possible moves for a pawn (of either color) in a given position' do
    end
  end

  describe '#vertical_collision?' do
    xit 'returns an array of all possible moves for a pawn (of either color) in a given position' do
    end
  end

  describe '#horizontal_collision?' do
    xit 'returns an array of all possible moves for a pawn (of either color) in a given position' do
    end
  end

  describe '#diagonal_collision?' do
    xit 'returns an array of all possible moves for a pawn (of either color) in a given position' do
    end
  end

  describe '#valid_move_path' do
    context 'when the move path is valid for a vertical move' do
      it 'returns true' do
        piece = Piece.new(color: 'white', currentPosition: 'a3', pieceType: 'rook')
        expect(piece.valid_move_path?('a7', ['a8', 'a2'])).to be true
      end

      it 'returns true' do
        piece = Piece.new(color: 'white', currentPosition: 'a7', pieceType: 'rook')
        expect(piece.valid_move_path?('a3', ['a8', 'a2'])).to be true
      end
    end

    context 'when the move path not is valid for a vertical move' do
      it 'returns false' do
        piece = Piece.new(color: 'white', currentPosition: 'a3', pieceType: 'rook')
        expect(piece.valid_move_path?('a7', ['a8', 'a2', 'a5'])).to be false
      end

      it 'returns false' do
        piece = Piece.new(color: 'white', currentPosition: 'a7', pieceType: 'rook')
        expect(piece.valid_move_path?('a3', ['a8', 'a2', 'a5'])).to be false
      end
    end

    context 'when the move path is valid for a horizontal move' do
      it 'returns true' do
        piece = Piece.new(color: 'white', currentPosition: 'a3', pieceType: 'rook')
        expect(piece.valid_move_path?('e3', ['a8', 'a2'])).to be true
      end

      it 'returns true' do
        piece = Piece.new(color: 'white', currentPosition: 'e7', pieceType: 'rook')
        expect(piece.valid_move_path?('a7', ['a8', 'a2'])).to be true
      end
    end

    context 'when the move path not is valid for a vertical move' do
      it 'returns false' do
        piece = Piece.new(color: 'white', currentPosition: 'a3', pieceType: 'rook')
        expect(piece.valid_move_path?('e3', ['a8', 'c3', 'a5'])).to be false
      end

      it 'returns false' do
        piece = Piece.new(color: 'white', currentPosition: 'a3', pieceType: 'rook')
        expect(piece.valid_move_path?('e3', ['a8', 'c3', 'a5'])).to be false
      end
    end

    context 'when the move path is valid for a diagonal move' do
      it 'returns true' do
        piece = Piece.new(color: 'white', currentPosition: 'd4', pieceType: 'bishop')
        expect(piece.valid_move_path?('f6', ['a8', 'a2'])).to be true
      end

      it 'returns true' do
        piece = Piece.new(color: 'white', currentPosition: 'f6', pieceType: 'rook')
        expect(piece.valid_move_path?('d4', ['a8', 'a2'])).to be true
      end
    end

    context 'when the move path is valid for a diagonal move' do
      it 'returns true' do
        piece = Piece.new(color: 'white', currentPosition: 'f3', pieceType: 'bishop')
        expect(piece.valid_move_path?('d5', ['a8', 'a2'])).to be true
      end

      it 'returns true' do
        piece = Piece.new(color: 'white', currentPosition: 'd5', pieceType: 'rook')
        expect(piece.valid_move_path?('f3', ['a8', 'a2'])).to be true
      end
    end

    context 'when the move path not is valid for a diagonal move' do
      it 'returns false' do
        piece = Piece.new(color: 'white', currentPosition: 'f3', pieceType: 'rook')
        expect(piece.valid_move_path?('d5', ['a8', 'e4', 'a5'])).to be false
      end

      it 'returns false' do
        piece = Piece.new(color: 'white', currentPosition: 'a3', pieceType: 'rook')
        expect(piece.valid_move_path?('e7', ['a8', 'd6', 'a5'])).to be false
      end
    end

    context 'when the piece is a knight or a king' do
      it 'returns true' do
        piece = Piece.new(color: 'white', currentPosition: 'f3', pieceType: 'knight')
        expect(piece.valid_move_path?('d4', ['a8', 'e4', 'a5'])).to be true
      end

      it 'returns false' do
        piece = Piece.new(color: 'white', currentPosition: 'a3', pieceType: 'rook')
        expect(piece.valid_move_path?('a4', ['a8', 'd6', 'a5'])).to be true
      end
    end
  end

  describe '#valid_destination' do
    context 'when the destination is a different color than the piece moving' do
      let(:game) {
        Game.create(
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white'
        )
      }

      it 'returns true' do

        piece = game.pieces.create(color: 'white', currentPosition: 'a3', pieceType: 'rook')
        game.pieces.create(color: 'black', currentPosition: 'a4', pieceType: 'rook')

        expect(piece.valid_destination?('a4')).to be true
      end
    end

    context 'when the destination is empty' do
      let(:game) {
        Game.create(
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white'
        )
      }
      it 'returns true' do
        piece = game.pieces.create(
          color: 'white',
          currentPosition: 'a3',
          pieceType: 'rook',
          startIndex: 25
        )
        game.pieces.create(
          color: 'black',
          currentPosition: 'a7',
          pieceType: 'rook',
          startIndex: 32
        )

        expect(piece.valid_destination?('a4')).to be true
      end
    end

    context 'when the destination is occupied by an allied piece' do
      let(:game) {
        Game.create(
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white'
        )
      }

      it 'returns false' do
        piece = game.pieces.find_by(startIndex: 17)

        game.pieces.find_by(startIndex: 9).update(
          color: 'white',
          currentPosition: 'a7',
          pieceType: 'rook',
          startIndex: 32
        )

        expect(piece.valid_destination?('a7')).to be false
      end
    end
  end

  describe '#king_is_safe?' do
    context 'when the king is not in check' do
      let(:game) {
        Game.create(
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white'
        )
      }

      it 'returns true' do
        piece = game.pieces.find_by(startIndex: 25)
        piece.update(currentPosition: 'a3')

        game.pieces.find_by(startIndex: 5).update(currentPosition: 'd6')

        expect(piece.king_is_safe?('black', game.pieces)).to be true
      end
    end

    context 'when the king is in check' do
      let(:game) {
        Game.create(
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white'
        )
      }

      it 'returns false' do
        piece = game.pieces.find_by(startIndex: 25)
        piece.update(currentPosition: 'd4')

        game.pieces.find_by(startIndex: 5).update(currentPosition: 'd6')
        expect(piece.king_is_safe?('black', game.pieces)).to be false
      end
    end
  end

  describe '#pieces_with_next_move' do
    xit 'test' do
    end
  end

  describe '#valid_moves' do
    xit 'test' do
    end
  end

  describe '#handle_moved_two' do
    xit 'test' do
    end
  end

  describe '#valid_for_piece' do
    context 'when a king can castle' do
      let(:game) {
        Game.create(
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white'
        )
      }
      before do
        game.pieces.where(currentPosition: ['f1', 'g1']).destroy_all
      end

      it 'returns true when the next move is a castle' do
        piece = game.pieces.find_by(startIndex: 29)
        expect(piece.valid_for_piece?('g1', game.pieces)).to be true
      end
    end

    context 'when a king cannot castle due to having moved' do
      let(:game) {
        Game.create(
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white'
        )
      }
      before do
        game.pieces.where(currentPosition: ['f1', 'g1']).destroy_all
      end

      it 'returns false when the next move is a castle' do
        piece = game.pieces.find_by(startIndex: 29)
        piece.update(hasMoved: true)

        expect(piece.valid_for_piece?('g1', game.pieces)).to be false
      end
    end

    context 'when a king cannot castle due to it\'s rook moving' do
      let(:game) {
        Game.create(
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white'
        )
      }

      before do
        game.pieces.where(currentPosition: ['f1', 'g1']).destroy_all
      end

      it 'returns false when the next move is a castle' do
        rook = game.pieces.find_by(startIndex: 32)
        rook.update(hasMoved: true)

        king = game.pieces.find_by(startIndex: 29)

        expect(king.valid_for_piece?('g1', game.pieces)).to be false
      end
    end

    context 'when a king cannot castle due to it\'s rook not being present' do
      let(:game) {
        Game.create(
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white'
        )
      }

      before do
        game.pieces.where(currentPosition: ['f1', 'g1', 'h1']).destroy_all
      end

      it 'returns false when the next move is a castle' do
        king = game.pieces.find_by(startIndex: 29)

        expect(king.valid_for_piece?('g1', game.pieces)).to be false
      end
    end

    context 'when a king cannot castle due to being in check' do
      let(:game) {
        Game.create(
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white'
        )
      }

      before do
        game.pieces.where(currentPosition: ['e2', 'f1', 'g1', 'e7']).destroy_all
        game.pieces.find_by(startIndex: 4).update(currentPosition: 'e7')
      end

      it 'returns false when the next move is a castle' do
        game.pieces.reload
        king = game.pieces.find_by(startIndex: 29)

        expect(king.valid_for_piece?('g1', game.pieces)).to be false
      end
    end

    context 'when a king cannot castle due to moving through check' do
      xit 'returns false when the next move is a castle' do
      end
    end
  end

  describe '#can_castle?' do
    xit 'test' do
    end
  end

  describe '#can_en_pessant?' do
    xit 'test' do
    end
  end

  describe '#valid_for_pawn?' do
    context 'when the pawn moves one space forward and the space is open' do
      let(:game) {
        Game.create(
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white'
        )
      }
      it 'returns true' do
        piece = game.pieces.find_by(currentPosition: 'd2')
        expect(piece.valid_for_pawn?('d3', game.pieces)).to be true
      end
    end

    context 'when the pawn moves one space forward and the space is not open' do
      let(:game) {
        Game.create(
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white'
        )
      }

      before do
        game.pieces.find_by(currentPosition: 'd2').update(currentPosition: 'd4')
        game.pieces.find_by(currentPosition: 'd7').update(currentPosition: 'd5')
      end

      it 'returns false' do
        piece = game.pieces.find_by(currentPosition: 'd4')
        expect(piece.valid_for_pawn?('d5', game.pieces)).to be false
      end
    end

    context 'when the black pawn moves one space forward and the space is open' do
      let(:game) {
        Game.create(
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white'
        )
      }
      it 'returns true' do
        piece = game.pieces.find_by(currentPosition: 'd7')
        expect(piece.valid_for_pawn?('d6', game.pieces)).to be true
      end
    end

    context 'when the black pawn moves one space forward and the space is not open' do
      let(:game) {
        Game.create(
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white'
        )
      }

      before do
        game.pieces.find_by(currentPosition: 'd7').update(currentPosition: 'd5')
        game.pieces.find_by(currentPosition: 'd2').update(currentPosition: 'd4')
      end

      it 'returns false' do
        piece = game.pieces.find_by(currentPosition: 'd5')
        expect(piece.valid_for_pawn?('d4', game.pieces)).to be false
      end
    end
  end

  context 'when the pawn moves two spaces forward and the space is open' do
    let(:game) {
      Game.create(
        challengedEmail: Faker::Internet.email,
        challengedName: Faker::Name.name,
        challengerColor: 'white'
      )
    }

    it 'returns false' do
      piece = game.pieces.find_by(currentPosition: 'd2')
      expect(piece.valid_for_pawn?('d4', game.pieces)).to be true
    end
  end

  context 'when the pawn moves two spaces forward and the space is not open' do
    let(:game) {
      Game.create(
        challengedEmail: Faker::Internet.email,
        challengedName: Faker::Name.name,
        challengerColor: 'white'
      )
    }

    before do
      game.pieces.find_by(currentPosition: 'd7').update(currentPosition: 'd4')
    end

    it 'returns false' do
      piece = game.pieces.find_by(currentPosition: 'd2')
      expect(piece.valid_for_pawn?('d4', game.pieces)).to be false
    end
  end

  context 'when the pawn moves two spaces forward and the pawn has already moved' do
    let(:game) {
      Game.create(
        challengedEmail: Faker::Internet.email,
        challengedName: Faker::Name.name,
        challengerColor: 'white'
      )
    }

    before do
      game.pieces.find_by(currentPosition: 'd2').update(hasMoved: true)
    end

    it 'returns false' do
      piece = game.pieces.find_by(currentPosition: 'd2')
      expect(piece.valid_for_pawn?('d4', game.pieces)).to be false
    end
  end

  context 'when the pawn attempts to move in the wrong direction' do
    let(:game) {
      Game.create(
        challengedEmail: Faker::Internet.email,
        challengedName: Faker::Name.name,
        challengerColor: 'white'
      )
    }

    before do
      game.pieces.find_by(currentPosition: 'd2').update(currentPosition: 'd4')
    end

    it 'returns false' do
      piece = game.pieces.find_by(currentPosition: 'd4')
      expect(piece.valid_for_pawn?('d3', game.pieces)).to be false
    end
  end

  context 'when the pawn attempts to capture a piece in the wrong direction' do
    let(:game) {
      Game.create(
        challengedEmail: Faker::Internet.email,
        challengedName: Faker::Name.name,
        challengerColor: 'white'
      )
    }

    before do
      game.pieces.find_by(currentPosition: 'd2').update(currentPosition: 'd4')
      game.pieces.find_by(currentPosition: 'e7').update(currentPosition: 'e3')
    end

    it 'returns false' do
      piece = game.pieces.find_by(currentPosition: 'd4')
      expect(piece.valid_for_pawn?('e3', game.pieces)).to be false
    end
  end

  context 'when the pawn attempts to capture a piece on an empty square' do
    let(:game) {
      Game.create(
        challengedEmail: Faker::Internet.email,
        challengedName: Faker::Name.name,
        challengerColor: 'white'
      )
    }

    before do
      game.pieces.find_by(currentPosition: 'd2').update(currentPosition: 'd4')
      game.pieces.find_by(currentPosition: 'e7').update(currentPosition: 'e5')
    end

    it 'returns false' do
      piece = game.pieces.find_by(currentPosition: 'd4')
      expect(piece.valid_for_pawn?('c5', game.pieces)).to be false
    end
  end

  context 'when the pawn attempts to capture a piece on an occupied square' do
    let(:game) {
      Game.create(
        challengedEmail: Faker::Internet.email,
        challengedName: Faker::Name.name,
        challengerColor: 'white'
      )
    }

    before do
      game.pieces.find_by(currentPosition: 'd2').update(currentPosition: 'd4')
      game.pieces.find_by(currentPosition: 'e7').update(currentPosition: 'e5')
    end

    it 'returns true' do
      piece = game.pieces.find_by(currentPosition: 'd4')
      expect(piece.valid_for_pawn?('e5', game.pieces)).to be true
    end
  end

  context 'when the pawn attempts to en passant a piece correctly' do
    let(:game) {
      Game.create(
        challengedEmail: Faker::Internet.email,
        challengedName: Faker::Name.name,
        challengerColor: 'white'
      )
    }

    before do
      game.pieces.find_by(currentPosition: 'd2').update(currentPosition: 'd5')
      game.pieces.find_by(currentPosition: 'e7')
          .update(currentPosition: 'e5', movedTwo: true)
    end

    it 'returns true' do
      piece = game.pieces.find_by(currentPosition: 'd5')
      expect(piece.valid_for_pawn?('e6', game.pieces)).to be true
    end
  end

  context 'when the pawn attempts to en passant a piece that has not movedTwo' do
    let(:game) {
      Game.create(
        challengedEmail: Faker::Internet.email,
        challengedName: Faker::Name.name,
        challengerColor: 'white'
      )
    }

    before do
      game.pieces.find_by(currentPosition: 'd2').update(currentPosition: 'd5')
      game.pieces.find_by(currentPosition: 'e7').update(currentPosition: 'e5')
    end

    it 'returns false' do
      piece = game.pieces.find_by(currentPosition: 'd5')
      expect(piece.valid_for_pawn?('e6', game.pieces)).to be false
    end
  end

  context 'when the pawn attempts to en passant in the wrong direction' do
    let(:game) {
      Game.create(
        challengedEmail: Faker::Internet.email,
        challengedName: Faker::Name.name,
        challengerColor: 'white'
      )
    }

    before do
      game.pieces.find_by(currentPosition: 'd2').update(currentPosition: 'd5')
      game.pieces.find_by(currentPosition: 'e7').update(currentPosition: 'e5', movedTwo: true)
    end

    it 'returns false' do
      piece = game.pieces.find_by(currentPosition: 'd5')
      expect(piece.valid_for_pawn?('e4', game.pieces)).to be false
    end
  end

  describe '#move_two?' do
    xit 'test' do
    end
  end

  describe '#advance_pawn?' do
    xit 'test' do
    end
  end
end
