require 'rails_helper'

RSpec.describe GamePiece, type: :model do
  it 'belongs_to a piece' do
    piece = Piece.create(
      pieceType: 'queen',
      color: 'white',
      currentPosition: 'b7',
      startIndex: Faker::Number.number(2)
    )

    game_piece = GamePiece.create(piece_id: piece.id)
    expect(game_piece.piece).to eq piece
  end

  it 'belongs_to a game' do
    game = Game.create(
      challengedEmail: Faker::Internet.email,
      challengedName: Faker::Name.name,
      challengerColor: 'whtie'
    )

    game_piece = UserGame.create(game_id: game.id)
    expect(game_piece.game).to eq game
  end
end
