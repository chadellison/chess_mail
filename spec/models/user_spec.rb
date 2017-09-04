require 'rails_helper'

RSpec.describe User, type: :model do
  let(:email) { Faker::Internet.email }
  let(:password) { 'password' }
  let(:first_name) { Faker::Name.first_name }
  let(:last_name) { Faker::Name.last_name }

  it 'has many games' do
    user = User.create(
      email: email,
      password: password,
      firstName: first_name,
      lastName: last_name
    )

    game = Game.create
    user.games << game

    expect(user.games).to eq [game]
  end

  it 'validates the presence of an email' do
    user = User.create(password: password,
                       firstName: first_name,
                       lastName: last_name)

    expect(user.valid?).to be false
    user.update(email: email)
    expect(user.valid?).to be true
  end

  it 'validates the uniqueness of an email' do
    user = User.create(email: email,
                       password: 'password2',
                       firstName: Faker::Name.first_name,
                       lastName: Faker::Name.last_name)

    user = User.create(email: email,
                       password: password,
                       firstName: first_name,
                       lastName: last_name)

    expect(user.valid?).to be false
  end

  it 'validates the presence of a password' do
    user = User.create(email: email,
                       firstName: first_name,
                       lastName: last_name)

    expect(user.valid?).to be false

    user.update(password: password)
    expect(user.valid?).to be true
  end

  it 'validates the presence of a first name' do
    user = User.create(email: email,
                       password: password,
                       lastName: last_name)

    expect(user.valid?).to be false
    user.update(firstName: first_name)
    expect(user.valid?).to be true
  end

  it 'validates the presence of a last name' do
    user = User.create(email: email,
                       password: password,
                       firstName: first_name)

    expect(user.valid?).to be false
    user.update(lastName: last_name)
    expect(user.valid?).to be true
  end

  describe 'serialize_user' do
    it 'returns a json api serialzed user' do
      token = 'token'
      hashed_email = Faker::Internet.email

      user = User.new(email: Faker::Internet.email,
                      password: password,
                      firstName: first_name,
                      lastName: last_name,
                      token: token,
                      hashed_email: hashed_email)

      expect(user.serialize_user[:data][:attributes][:hashed_email]).to eq hashed_email
      expect(user.serialize_user[:data][:attributes][:token]).to eq token
      expect(user.serialize_user[:data][:attributes][:firstName]).to eq first_name
      expect(user.serialize_user[:data][:attributes][:lastName]).to eq last_name
    end

    it 'returns a json api serialzed user with their relationships' do
      token = 'token'
      hashed_email = Faker::Internet.email

      user = User.create(email: Faker::Internet.email,
                         password: password,
                         firstName: first_name,
                         lastName: last_name,
                         token: token,
                         hashed_email: hashed_email)

      game1 = user.games.create
      game2 = Game.create
      game3 = Game.create(challenged_email: user.email)

      serialzed_games = Game.serialize_games([game1, game3], user.email)[:data]

      expect(user.serialize_user[:data][:included].length).to eq 2
      expect(user.serialize_user[:data][:included]).to eq serialzed_games
    end
  end

  context 'before_save' do
    describe 'hashed_email' do
      it 'returns a hash of the user\'s email' do
        user = User.create(email: Faker::Internet.email,
                 password: Faker::Internet.password,
                 firstName: first_name,
                 lastName: last_name
               )

        expect(user.hashed_email).to eq Digest::MD5.hexdigest(user.email)
      end
    end
  end

  describe '#send_confirmation_email' do
    xit 'test' do
    end
  end
end
