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

      let(:move_params) {
        {
          currentPosition: 'd5',
          startIndex: 12,
          hasMoved: true,
          pieceType: 'pawn'
        }
      }

      it 'updates a user\'s game' do
        post :create, params: {
          id: game.id,
          token: user.token,
          move: move_params
        }, format: :json

        expect(response.status).to eq 201
        parsed_response = JSON.parse(response.body).deep_symbolize_keys
        expect(parsed_response[:data][:included][:moves].last[:attributes][:startIndex])
          .to eq move_params[:startIndex]
        expect(game.pieces.find_by(startIndex: 12).currentPosition)
          .to eq move_params[:currentPosition]
      end

      it 'calls send_new_move_email' do
        allow_any_instance_of(Game).to receive(:stalemate?).and_return(false)
        allow_any_instance_of(Game).to receive(:checkmate?).and_return(false)

        expect_any_instance_of(Game).to receive(:send_new_move_email)
        post :create, params: { id: game.id, token: user.token,
                                move: move_params }, format: :json
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

      let(:move_params) do
        {
          startIndex: 1,
          currentPosition: 'a6',
          movedTwo: false
        }
      end

      it 'returns a 404' do
        expect {
          post :create, params: { game_id: Faker::Number.number(8),
                                  token: user.token,
                                  move: move_params }, format: :json
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#show' do
    it 'retrieves a created ai move on the game' do
      game = Game.new(
        human: false,
        robot: true,
        move_signature: 'd4.',
        challengedEmail: Faker::Internet.email
      )
      game.save(validate: false)
      game.moves.create(
        notation: 'd4.',
        color: 'white',
        pieceType: 'pawn',
        currentPosition: 'd4'
      )

      expect {
        get :show, params: { id: game.id }
      }.to change { game.moves.count }.by(1)

      expect(response.status).to eq 201
      parsed_response = JSON.parse(response.body).deep_symbolize_keys
      expect(parsed_response[:data][:included][:moves].first[:type]).to eq 'move'
      expect(parsed_response[:data][:included][:moves].count).to eq 2
      expect(parsed_response[:data][:included][:moves].first[:attributes][:color]).to eq 'white'
      expect(parsed_response[:data][:included][:moves].first[:attributes][:currentPosition]).to eq 'd4'
      expect(parsed_response[:data][:included][:moves].last[:attributes][:color]).to eq 'black'
    end
  end
end
