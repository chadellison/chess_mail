require 'rails_helper'

RSpec.describe Game, type: :model do
  let(:email) { Faker::Internet.email }
  let(:password) { "password" }
  let(:first_name) { Faker::Name.first_name }
  let(:last_name) { Faker::Name.last_name }

  it "has many users" do
    user = User.create(
      email: email,
      password: password,
      firstName: first_name,
      lastName: last_name
    )

    game = Game.create
    game.users << user

    expect(game.users).to eq [user]
  end
end
