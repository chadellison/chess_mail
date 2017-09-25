require 'rails_helper'

RSpec.describe MoveLogic, type: :model do
  describe '#moves_up' do
    it 'returns an array of all possible moves up given a position' do
      position = 'f3'
      expected = ['f4', 'f5', 'f6', 'f7', 'f8']

      expect(MoveLogic.moves_up(position)).to eq expected
    end
  end

  describe '#moves_down' do
    it 'returns an array of all possible moves down given a position' do
      position = 'f3'
      expected = ['f2', 'f1']

      expect(MoveLogic.moves_down(position)).to eq expected
    end
  end

  describe '#moves_left' do
    it 'returns an array of all possible moves left given a position' do
      position = 'f3'
      expected = ['e3', 'd3', 'c3', 'b3', 'a3']

      expect(MoveLogic.moves_left(position)).to eq expected
    end
  end

  describe '#moves_right' do
    it 'returns an array of all possible moves right given a position' do
      position = 'f3'
      expected = ['g3', 'h3']

      expect(MoveLogic.moves_right(position)).to eq expected
    end
  end

  describe '#moves_for_rook' do
    it 'returns an array of all possible moves for a rook in a given position' do
      position = 'd4'
      expected = ['d5', 'd6', 'd7', 'd8', 'd3', 'd2', 'd1', 'c4', 'b4', 'a4',
                  'e4', 'f4', 'g4', 'h4']

      expect(MoveLogic.moves_for_rook(position)).to eq expected
    end
  end

  describe '#moves_for_bishop' do
    it 'returns an array of all possible moves for a bishop in a given position' do
      position = 'd4'
      expected = ['e5', 'f6', 'g7', 'h8', 'c5', 'b6', 'a7', 'c3', 'b2', 'a1',
                  'e3', 'f2', 'g1']

      expect(MoveLogic.moves_for_bishop(position)).to eq expected
    end
  end

  describe '#extract_diagonals' do
    it 'returns an array of each set\'s first coordinate\'s column and second corrdinate\'s row' do
      expect(MoveLogic.extract_diagonals([['b2', 'a3']])).to eq ['b3']
    end
  end

  describe '#moves_for_queen' do
    it 'returns an array of all possible moves for a queen in a given position' do
      position = 'd4'
      expected = ['d5', 'd6', 'd7', 'd8', 'd3', 'd2', 'd1', 'c4', 'b4', 'a4',
                  'e4', 'f4', 'g4', 'h4', 'e5', 'f6', 'g7', 'h8', 'c5', 'b6',
                  'a7', 'c3', 'b2', 'a1', 'e3', 'f2', 'g1']

      expect(MoveLogic.moves_for_queen(position)).to eq expected
    end
  end

  describe '#moves_for_king' do
    it 'returns an array of all possible moves for a king in a given position' do
      position = 'd4'
      expected = ["d5", "d3", "c4", "e4", "e5", "c5", "c3", "e3", "b4", "f4"]

      expect(MoveLogic.moves_for_king(position)).to eq expected
    end
  end

  describe '#moves_for_knight' do
    it 'returns an array of all possible moves for a knight in a given position' do
      position = 'd4'
      expected = ["b5", "b3", "f5", "f3", "c6", "c2", "e6", "e2"]

      expect(MoveLogic.moves_for_knight(position)).to eq expected
    end
  end
end
