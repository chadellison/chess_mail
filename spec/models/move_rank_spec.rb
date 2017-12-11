require 'rails_helper'

RSpec.describe MoveRank, type: :model do
  it 'validates the presence of a position_signature' do
    move_rank = MoveRank.create
    expect(move_rank).not_to be_valid

    move_rank = MoveRank.create(position_signature: '1:a8')
    expect(move_rank).to be_valid
  end

  it 'has many move_rank_games' do
    move_rank = MoveRank.create(position_signature: '1:a8')
    move_rank_game = move_rank.move_rank_games.create
    expect(move_rank.move_rank_games).to eq [move_rank_game]
  end

  it 'has many games' do
    move_rank = MoveRank.create(position_signature: '1:a8')
    game = move_rank.games.create
    expect(move_rank.games).to eq [game]
  end

  it 'has many next_positions' do
    move_rank = MoveRank.create(position_signature: '1:a8')

    next_position = move_rank.next_positions.create(position_signature: '1:a7')
    expect(move_rank.next_positions).to eq [next_position]
  end

  describe '#move_data' do
    xit 'test' do
    end
  end

  describe '#craete_move_data' do
    xit 'test' do
    end
  end

  describe '#add_next_positions' do
    xit 'test' do
    end
  end
end
