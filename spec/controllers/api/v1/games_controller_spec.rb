require 'rails_helper'

RSpec.describe Api::V1::GamesController, type: :controller do
  describe 'authenticate_with_token' do
    context 'when the user is not authenticated' do
      it 'returns a 404 with record not found' do
        user = User.new
        expect { get :index, params: { token: user.token }, format: :json }
          .to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#index' do
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
      get :index, params: { token: user.token }, format: :json

      expect(response.status).to eq 200
      expect(JSON.parse(response.body).deep_symbolize_keys[:data].first[:id]).to eq game1.id
      expect(JSON.parse(response.body).deep_symbolize_keys[:data].last[:id]).to eq game2.id
    end
  end

  describe '#show' do
    context 'when the game exists' do
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

      let!(:game) { user.games.create }

      it 'returns a user\'s serialized game' do
        get :show, params: { id: game.id, token: user.token }, format: :json

        expect(response.status).to eq 200
        expect(JSON.parse(response.body).deep_symbolize_keys[:data][:id]).to eq game.id
        expect(JSON.parse(response.body).deep_symbolize_keys[:data][:type]).to eq 'game'
      end
    end

    context 'when the game does not exist' do
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

      it 'returns a 404' do
        expect{
          get :show, params: { id: Faker::Number.number(4), token: user.token }, format: :json
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#update' do
    context 'when the game exists' do
      let(:email) { Faker::Internet.email }
      let(:password) { 'password' }
      let(:first_name) { Faker::Name.first_name }
      let(:last_name) { Faker::Name.last_name }
      let(:token) { 'token' }

      let(:user) {
        User.create(email: email,
        password: password,
        firstName: first_name,
        lastName: last_name,
        approved: true,
        token: token)
      }

      let(:game) { user.games.create }
      let(:piece) { Piece.create(pieceType: 'rook', color: 'black', currentPosition: 'a6') }

      let(:piece_params) {
        {
          id: piece.id,
          pieceType: piece.pieceType,
          color: piece.color,
          currentPosition: piece.currentPosition
        }
      }

      it 'updates a user\'s game' do
        expect{
          get :update, params: { id: game.id, token: user.token, piece: piece_params }, format: :json
        }.to change{ game.pieces.count}.by(1)

        expect(response.status).to eq 204
        expect(game.pieces).to eq [piece]
      end
    end

    context 'when the game does not exist' do
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

      let(:piece) { Piece.create(pieceType: 'rook', color: 'black', currentPosition: 'a6') }

      let(:piece_params) {
        {
          id: piece.id,
          pieceType: piece.pieceType,
          color: piece.color,
          currentPosition: piece.currentPosition
        }
      }

      it 'returns a 404' do
        expect{
          get :update, params: { id: Faker::Number.number(8),
                                  token: user.token,
                                  piece: piece_params }, format: :json
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end
end
