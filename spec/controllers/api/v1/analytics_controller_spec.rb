require 'rails_helper'

RSpec.describe Api::V1::AnalyticsController, type: :controller do
  describe '#show' do
    context 'with the proper parameters' do
      xit 'returns a 200 status' do
        params = { moves: {} }

        get :index, params: params, format: :json

        expect(response.status).to eq 200
      end

      xit 'returns a hash with the number of wins, losses, and drawn games' do
        game1 = Game.create(
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          challengerColor: 'white',
          outcome: 'white wins',
          move_signature: ' 20:d4'
        )

        game2 = Game.create(
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          challengerColor: 'white',
          outcome: 'white wins',
          move_signature: ' 20:d4'
        )

        game3 = Game.create(
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          challengerColor: 'white',
          outcome: 'black wins',
          move_signature: ' 20:d4'
        )

        move = {
          startIndex: 22,
          type: 'pawn',
          color: 'white',
          currentPosition: 'd4'
        }

        params = { moves: move }

        get :index, params: params, format: :json

        expect(JSON.parse(response.body)['data']['attributes']['white']).to eq 2
        expect(JSON.parse(response.body)['data']['attributes']['black']).to eq 1
        expect(JSON.parse(response.body)['data']['attributes']['draw']).to eq 1
      end
    end
  end
end
