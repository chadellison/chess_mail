require 'rails_helper'

describe Analysis do
  describe 'serialize' do
    it 'returns json api data about the given move signature' do
      game1 = Game.create(
        challengedName: Faker::Name.first_name,
        challengedEmail: Faker::Internet.email,
        challengerColor: 'white',
        robot: true,
        outcome: 'white wins',
        move_signature: ' 20:d4'
      )

      game2 = Game.create(
        challengedName: Faker::Name.first_name,
        challengedEmail: Faker::Internet.email,
        challengerColor: 'black',
        robot: true,
        outcome: 'black wins',
        move_signature: ' 20:d4'
      )

      game3 = Game.create(
        challengedName: Faker::Name.first_name,
        challengedEmail: Faker::Internet.email,
        challengerColor: 'white',
        robot: true,
        outcome: 'white wins',
        move_signature: ' 20:d4'
      )

      signature = ' 20:d4'

      expected = {
        data: {
          type: 'move_signature',
          attributes: { whiteWins: 2, blackWins: 1, draws: 0
          }
        }
      }

      result = Analysis.serialize(signature)

      expect(result).to eq expected
    end
  end
end
