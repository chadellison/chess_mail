require 'rails_helper'

RSpec.describe User, type: :model do
  let(:email) { Faker::Internet.email }
  let(:password) { "password" }

  it "validates the presence of an email" do
    user = User.create(password: password)

    expect(user.valid?).to be false
    user.update(email: email)
    expect(user.valid?).to be true
  end

  it "validates the uniqueness of an email" do
    User.create(email: email,
                password: password)

    user = User.create(email: email,
                       password: password)

    expect(user.valid?).to be false
  end

  it "validates the presence of a password" do
    user = User.create(email: email)
    expect(user.valid?).to be false

    user.update(password: password)
    expect(user.valid?).to be true
  end

  describe 'serialize_user' do
    it 'returns a json api serialzed user' do
      token = 'token'
      hashed_email = Faker::Internet.email

      user = User.new(email: Faker::Internet.email,
                      password: password,
                      token: token,
                      hashed_email: hashed_email)

      expect(user.serialize_user[:data][:attributes][:hashed_email]).to eq hashed_email
      expect(user.serialize_user[:data][:attributes][:token]).to eq token
    end
  end

  context 'before_save' do
    describe 'hashed_email' do
      it "returns a hash of the user's email" do
        user = User.create(email: Faker::Internet.email,
        password: Faker::Internet.password)

        expect(user.hashed_email).to eq Digest::MD5.hexdigest(user.email)
      end
    end
  end
end
