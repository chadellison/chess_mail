require 'rails_helper'

RSpec.describe Move, type: :model do
  it 'belongs to a game' do
    move = Move.new(
      currentPosition: 'a2',
      pieceType: 'knight',
      color: 'white',
      startIndex: Faker::Number.number(2)
    )
    game = Game.new
    game.moves << move

    expect(move.game).to eq game
  end

  describe '#serialize_move' do
    xit 'test' do
    end
  end
end
