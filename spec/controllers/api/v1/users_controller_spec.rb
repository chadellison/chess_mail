require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  describe 'create' do
    context 'with incomplete information' do
      it 'returns an error' do
        email = Faker::Internet.email

        body = { user: {
            email: email,
            password: ""
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

      it 'creates a user' do
        body = {
          user: {
            email: email,
            password: Faker::Number.number(8),
          }
        }

        expect {
          post :create, params: body, format: :json
        }.to change { User.count }.by(1)

        expect(response.status).to eq 201
        expect(JSON.parse(response.body)["data"]["attributes"]["hashed_email"]).to be_present
      end
    end
  end
end
