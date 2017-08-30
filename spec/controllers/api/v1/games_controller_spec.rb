require 'rails_helper'

RSpec.describe Api::V1::GamesController, type: :controller do
  describe 'index' do
    context 'when the user is not authenticated' do
      it 'returns a 404 with record not found' do
        user = User.new
        user.id = Faker::Number.number(8)
        expect { get :index, params: { user_id: user.id, token: user.token }, format: :json }
          .to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the user is authenticated' do
      let(:email) { Faker::Internet.email }
      let(:password) { 'password' }
      let(:first_name) { Faker::Name.first_name }
      let(:last_name) { Faker::Name.last_name }
      let(:token) { 'token' }

      let!(:user) {
        User.create(email: email,
        password: password,
        firstName: first_name,
        lastName: last_name,
        approved: true,
        token: token)
      }

      let!(:game1) { user.games.create }
      let!(:game2) { user.games.create }

      it 'returns all of that users\'s games' do
        expected = { data: user.games, meta: { count: 2 } }

        get :index, params: { user_id: user.id, token: user.token }, format: :json

        expect(response.status).to eq 200
        expect(JSON.parse(response.body).deep_symbolize_keys[:data].first[:id]).to eq game1.id
        expect(JSON.parse(response.body).deep_symbolize_keys[:data].last[:id]).to eq game2.id
      end
    end
  end
end
