require 'rails_helper'

RSpec.describe MoveRank, type: :model do
  it 'has many move_rank_games' do
    move_rank = MoveRank.create
    expect(move_rank).to respond_to :move_rank_games
  end

  it 'has many games' do
    move_rank = MoveRank.create
    expect(move_rank).to respond_to :games
  end

  describe '#find_start_index' do
    xit 'test' do
    end
  end
end
