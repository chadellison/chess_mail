require 'rails_helper'

RSpec.describe Api::V1::AnalyticsController, type: :controller do
  describe '#show' do
    context 'with the proper parameters' do
      it 'returns a 200 status' do
        patch :analysis, params: { moves: {moveSignature: '' } }, format: :json

        expect(response.status).to eq 200
      end

      it 'returns a hash with the number of wins, losses, and drawn games' do
        game1 = Game.create(
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          challengerColor: 'white',
          outcome: 'white wins',
          move_signature: ' 20:d4',
          human: false
        )

        game2 = Game.create(
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          challengerColor: 'white',
          outcome: 'white wins',
          move_signature: ' 20:d4',
          human: false
        )

        game3 = Game.create(
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          challengerColor: 'white',
          outcome: 'black wins',
          move_signature: ' 20:d4',
          human: false
        )

        move = {
          startIndex: 20,
          type: 'pawn',
          color: 'white',
          currentPosition: 'd4'
        }

        patch :analysis, params: { moves: { moveSignature: ' 20:d4' } }, format: :json

        expect(JSON.parse(response.body)['data']['attributes']['whiteWins']).to eq 2
        expect(JSON.parse(response.body)['data']['attributes']['blackWins']).to eq 1
        expect(JSON.parse(response.body)['data']['attributes']['draws']).to eq 0
      end
    end
  end
end
