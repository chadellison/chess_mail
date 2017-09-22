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
