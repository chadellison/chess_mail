require 'rails_helper'

RSpec.describe MoveRankGame, type: :model do
  xit 'belongs to a move_rank' do
    move_rank_game = MoveRankGame.create
    expect(move_rank_game).to respond_to :move_rank
  end

  xit 'belongs to a game' do
    move_rank_game = MoveRankGame.create
    expect(move_rank_game).to respond_to :game
  end

  xit 'must have a unuique position_signature' do
  end
end
