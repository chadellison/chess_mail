require 'rails_helper'

RSpec.describe Game, type: :model do
  let(:email) { Faker::Internet.email }
  let(:password) { 'password' }
  let(:first_name) { Faker::Name.first_name }
  let(:last_name) { Faker::Name.last_name }

  it 'has many users' do
    user = User.create(
      email: email,
      password: password,
      firstName: first_name,
      lastName: last_name
    )

    game = Game.create
    game.users << user

    expect(game.users).to eq [user]
  end

  it 'has many pieces' do
    piece = Piece.create(
      pieceType: 'rook',
      color: 'black',
      currentPosition: 'a2',
    )

    game = Game.create
    game.pieces << piece

    expect(game.pieces).to eq [piece]
  end

  describe '#serialize_games' do
    xit 'serializes the passed in games' do
    end
  end

  describe '#serialize_game' do
    xit 'serializes a game instance' do
    end
  end
end
