require 'rails_helper'

RSpec.describe TrainingGame, type: :model do
  it 'validates the uniqueness of the moves' do
    training_game = TrainingGame.create(moves: '1.a4Nf6')
    duplicate_moves = TrainingGame.new(moves: '1.a4Nf6')

    expect(duplicate_moves.valid?).to be false
    expect(duplicate_moves.errors[:moves].first).to eq 'has already been taken'
  end
end
