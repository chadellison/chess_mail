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

    game = Game.create(
      human: true,
      challengedEmail: Faker::Internet.email,
      challengedName: Faker::Name.name,
      challengerColor: 'white'
    )

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

  context 'before_save' do
    describe 'hashed_email' do
      it 'returns a hash of the user\'s email' do
        user = User.create(
          email: Faker::Internet.email,
          password: Faker::Internet.password,
          firstName: first_name,
          lastName: last_name
        )

        expect(user.hashed_email).to eq Digest::MD5.hexdigest(user.email)
      end
    end

    describe 'downcase_email' do
      it 'downcases the user\'s email' do
        user = User.create(
          email: 'CapitalEmail.com',
          password: Faker::Internet.password,
          firstName: first_name,
          lastName: last_name
        )

        expect(user.downcase_email).to eq 'capitalemail.com'
      end
    end
  end

  describe '#serialized_user_games' do
    xit 'test' do
    end
  end
end
