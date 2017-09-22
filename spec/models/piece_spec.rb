require 'rails_helper'

RSpec.describe Piece, type: :model do

  # id: 54,
 # currentPosition: "c5",
 # color: "black",
 # created_at: Fri, 22 Sep 2017 03:08:00 UTC +00:00,
 # updated_at: Fri, 22 Sep 2017 03:08:00 UTC +00:00,
 # pieceType: "knight",
 # hasMoved: true,
 # movedTwo: false,
 # startIndex: 7>
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

  it 'validates the presence of startIndex' do
    piece = Piece.new(
      currentPosition: 'a2',
      pieceType: 'knight',
      color: 'black'
    )

    expect(piece.valid?).to be false

    piece.update(startIndex: Faker::Number.number(2))
    expect(piece.valid?).to be true
  end

  it 'validates the presence a pieceType' do
    piece = Piece.new(
      currentPosition: 'a2',
      startIndex: Faker::Number.number(2),
      color: 'black'
    )

    expect(piece.valid?).to be false
    piece.update(pieceType: 'knight')
    expect(piece.valid?).to be true
  end
end
