require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  describe 'create' do
    context 'with incomplete information' do
      it 'returns an error' do
        email = Faker::Internet.email
        first_name = Faker::Name.first_name
        last_name = Faker::Name.last_name

        body = { user: {
            email: email,
            password: "",
            firstName: first_name,
            lastName: last_name
          }
        }

        expect {
          post :create, params: body, format: :json
        }.not_to change { User.count }

        expect(response.status).to eq 400
        error_message = "password can't be blank"
        expect(JSON.parse(response.body)['errors']).to eq error_message
      end
    end

    context 'with complete information' do
      let(:email) { Faker::Internet.email }
      let(:first_name) { Faker::Name.first_name }
      let(:last_name) { Faker::Name.last_name }

      it 'creates a user' do
        body = {
          user: {
            email: email,
            password: Faker::Number.number(8),
            firstName: first_name,
            lastName: last_name
          }
        }

        expect {
          post :create, params: body, format: :json
        }.to change { User.count }.by(1)

        expect(response.status).to eq 201
        expect(JSON.parse(response.body)["data"]["attributes"]["hashed_email"]).to be_present
        expect(JSON.parse(response.body)["data"]["attributes"]["firstName"]).to eq first_name
        expect(JSON.parse(response.body)["data"]["attributes"]["lastName"]).to eq last_name
      end

      it 'does not approve the user that is created' do
        body = {
          user: {
            email: email,
            password: Faker::Number.number(8),
            firstName: first_name,
            lastName: last_name
          }
        }

        post :create, params: body, format: :json

        expect(User.find_by(email: email).approved).to be false
      end
    end
  end

  describe '#approve' do
    context 'when the user is found' do
      let(:email) { Faker::Internet.email }
      let(:first_name) { Faker::Name.first_name }
      let(:last_name) { Faker::Name.last_name }
      let(:token) { 'token' }

      let!(:user) {
        User.create(email: email,
          password: "password",
          firstName: first_name,
          lastName: last_name,
          token: token,
          approved: false)
      }

      it 'approves the user and returns a 204 status' do
        user = User.find_by(token: token)
        ENV['host'] = 'localhost:3000'

        get :approve, params: { token: token }, format: :json
        expect(response).to redirect_to('localhost:3000')
        expect(user.reload.approved).to be true
      end
    end

    context 'when the user is not found' do
      let(:token) { 'token' }

      it 'returns a 404' do
        get :approve, params: { token: token }, format: :json
        expect(response.status).to eq 404
        expect(JSON.parse(response.body)["errors"]).to eq 'Not Found'
      end
    end
  end
end
