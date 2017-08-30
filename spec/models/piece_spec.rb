require 'rails_helper'

RSpec.describe Piece, type: :model do
  it 'has many games' do
    piece = Piece.create(
      piece_type: 'king',
      color: 'black',
      currentPosition: 'h3'
    )

    game = Game.create
    piece.games << game

    expect(piece.games).to eq [game]
  end
end
