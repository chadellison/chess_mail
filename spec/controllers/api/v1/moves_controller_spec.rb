require 'rails_helper'

RSpec.describe Api::V1::MovesController, type: :controller do
  describe '#create' do
    context 'when the game exists' do
      let(:email) { Faker::Internet.email }
      let(:password) { 'password' }
      let(:first_name) { Faker::Name.first_name }
      let(:last_name) { Faker::Name.last_name }
      let(:token) { 'token' }

      let(:user) do
        User.create(
          email: email,
          password: password,
          firstName: first_name,
          lastName: last_name,
          approved: true,
          token: token
        )
      end

      let(:game) do
        user.games.create(
          challengedEmail: Faker::Name.name,
          challengedName: Faker::Internet.email,
          challengerColor: 'whtie'
        )
      end

      let(:piece) do
        Piece.create(
          pieceType: 'rook',
          color: 'black',
          currentPosition: 'a6',
          startIndex: '27'
        )
      end

      let(:piece_params) {
        {
          pieceType: piece.pieceType,
          color: piece.color,
          currentPosition: piece.currentPosition,
          startIndex: piece.startIndex
        }
      }

      it 'updates a user\'s game' do
        expect {
          post :create, params: { game_id: game.id, token: user.token, piece: piece_params }, format: :json
        }.to change { game.pieces.count }.by(1)

        expect(response.status).to eq 201
        expect(JSON.parse(response.body)['data']['included']
          .first['attributes']['startIndex']).to eq piece.startIndex
        expect(game.pieces.first.startIndex).to eq piece.startIndex
      end

      it 'calls send_new_move_email' do
        expect_any_instance_of(Game).to receive(:send_new_move_email)
        post :create, params: { game_id: game.id, token: user.token, piece: piece_params }, format: :json
      end
    end

    context 'when the game does not exist' do
      let(:email) { Faker::Internet.email }
      let(:password) { 'password' }
      let(:first_name) { Faker::Name.first_name }
      let(:last_name) { Faker::Name.last_name }
      let(:token) { 'token' }

      let!(:user) do
        User.create(
          email: email,
          password: password,
          firstName: first_name,
          lastName: last_name,
          approved: true,
          token: token
        )
      end

      let(:piece) { Piece.create(pieceType: 'rook', color: 'black', currentPosition: 'a6') }

      let(:piece_params) do
        {
          pieceType: piece.pieceType,
          color: piece.color,
          currentPosition: piece.currentPosition
        }
      end

      it 'returns a 404' do
        expect {
          post :create, params: { game_id: Faker::Number.number(8),
                                 token: user.token,
                                 piece: piece_params }, format: :json
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end
end
