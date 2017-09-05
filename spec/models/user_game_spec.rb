require 'rails_helper'

RSpec.describe UserGame, type: :model do
  let(:email) { Faker::Internet.email }
  let(:password) { "password" }
  let(:first_name) { Faker::Name.first_name }
  let(:last_name) { Faker::Name.last_name }

  it 'belongs_to a user' do
    user = User.create(
      email: email,
      password: password,
      firstName: first_name,
      lastName: last_name
    )

    user_game = UserGame.create(user_id: user.id)
    expect(user_game.user).to eq user
  end

  it 'belongs_to a user' do
    game = Game.create(
      challengedEmail: Faker::Internet.email,
      challengedName: Faker::Name.name,
      challengerColor: 'black'
    )

    user_game = UserGame.create(game_id: game.id)
    expect(user_game.game).to eq game
  end
end
