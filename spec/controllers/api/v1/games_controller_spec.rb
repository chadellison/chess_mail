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

  describe '#create' do
    context 'against a human player' do
      context 'with valid parameters' do
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

        let!(:challengedUser) {
          User.create(email: 'bob@example.com',
          password: 'password',
          firstName: 'bob',
          lastName: 'jones',
          approved: true,
          token: 'other_token')
        }

        let(:game_params) {
          {
            game: {
              challengedName: challengedUser.firstName,
              challengedEmail: challengedUser.email,
              playerColor: 'white',
              challengePlayer: true,
              challengeRobot: false
            },
            token: user.token
          }
        }

        it 'creates and returns the game' do
          expect{
            post :create, params: game_params, format: :json
          }.to change{ user.games.count }.by(1)

          expect(response.status).to eq 201
          expect(JSON.parse(response.body)['data']['type']).to eq 'game'
          expect(JSON.parse(response.body)['data']['attributes']['pending']).to be true
        end

        context 'when the challenged player has an account' do
          it 'adds both players to the game' do

            post :create, params: game_params, format: :json
            game_id = JSON.parse(response.body)['data']['id']

            expect(Game.find(game_id).users.count).to eq 2
            expect(Game.find(game_id).users.first.id).to eq user.id
            expect(Game.find(game_id).users.last.id).to eq challengedUser.id
          end

          it 'sets the challenged user\'s email on the game' do
            post :create, params: game_params, format: :json
            game_id = JSON.parse(response.body)['data']['id']

            expect(Game.find(game_id).challenged_email).to eq challengedUser.email
          end
        end

        context 'when the challenged player does not have an account' do
          let(:challenged_email) { Faker::Internet.email }
          let(:challenged_name) { Faker::Name.first_name }

          let(:params) {
            {
              game: {
                challengedName: challenged_name,
                challengedEmail: challenged_email,
                playerColor: 'white',
                challengePlayer: true,
                challengeRobot: false
              },
              token: user.token
            }
          }

          it 'sets the challenged user\'s email on the game' do
            post :create, params: params, format: :json
            game_id = JSON.parse(response.body)['data']['id']

            expect(Game.find(game_id).challenged_email).to eq challenged_email
          end

          it 'adds only the user who initiated the challenge to the game' do
            post :create, params: params, format: :json
            game_id = JSON.parse(response.body)['data']['id']

            expect(Game.find(game_id).users.count).to eq 1
            expect(Game.find(game_id).users.first.id).to eq user.id
          end
        end
      end

      context 'when no name is passed in' do
        let(:challenged_email) { Faker::Internet.email }

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

        let(:game_params) {
          {
            game: {
              challengedName: '',
              challengedEmail: challenged_email,
              playerColor: 'white',
              challengePlayer: true,
              challengeRobot: false
            },
            token: user.token
          }
        }

        it 'does not create a game' do
          expect{
            post :create, params: game_params, format: :json
          }.not_to change{ Game.count }
        end

        it 'returns a json api error message' do
          error = 'Player name and player email must be filled.'
          post :create, params: game_params, format: :json

          expect(response.status).to eq 400
          expect(JSON.parse(response.body)['error']).to eq error
        end
      end

      context 'when no email is passed in' do
        let(:challenged_name) { Faker::Name.first_name }

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

        let(:game_params) {
          {
            game: {
              challengedName: challenged_name,
              challengedEmail: '',
              playerColor: 'white',
              challengePlayer: true,
              challengeRobot: false
            },
            token: user.token
          }
        }

        it 'does not create a game' do
          expect{
            post :create, params: game_params, format: :json
          }.not_to change{ Game.count }
        end

        it 'returns a json api error message' do
          error = 'Player name and player email must be filled.'
          post :create, params: game_params, format: :json

          expect(response.status).to eq 400
          expect(JSON.parse(response.body)['error']).to eq error
        end
      end

      context 'when the player has already submitted a challenge to the that person' do
        let(:email) { Faker::Internet.email }
        let(:password) { 'password' }
        let(:first_name) { Faker::Name.first_name }
        let(:last_name) { Faker::Name.last_name }
        let(:token) { 'token' }

        let!(:user) do
          User.create(email: email,
                      password: password,
                      firstName: first_name,
                      lastName: last_name,
                      approved: true,
                      token: token)
        end

        let!(:challengedUser) do
          User.create(email: 'bob@example.com',
                      password: 'password',
                      firstName: 'bob',
                      lastName: 'jones',
                      approved: true,
                      token: 'other_token')
        end

        let(:game_params) do
          {
            game: {
              challengedName: challengedUser.firstName,
              challengedEmail: challengedUser.email,
              playerColor: 'white',
              challengePlayer: true,
              challengeRobot: false
            },
            token: user.token
          }
        end

        it 'does not create a game' do
          user.games.create(challenged_email: challengedUser.email)

          expect{
            post :create, params: game_params, format: :json
          }.not_to change{ Game.count }
        end

        it 'returns a json api error message' do
          user.games.create(challenged_email: challengedUser.email)

          error = 'A game or challenge is already in progress for this person'
          post :create, params: game_params, format: :json
          expect(response.status).to eq 400
          expect(JSON.parse(response.body)['error']).to eq error
        end
      end
    end

    context 'against an AI player' do
      xit 'test' do
      end
    end
  end

  describe '#accept' do
    context 'when the player does not have an account' do
      let(:email) { Faker::Internet.email }
      let(:password) { 'password' }
      let(:first_name) { Faker::Name.first_name }
      let(:last_name) { Faker::Name.last_name }
      let(:token) { 'token' }

      let!(:user) do
        User.create(email: email,
                    password: password,
                    firstName: first_name,
                    lastName: last_name,
                    approved: true,
                    token: token)
      end

      let(:game) { user.games.create }

      it 'does not set the pending attribute on the game to false' do
        bad_token = 'bad_token'
        params = { game_id: game.id, token: bad_token }

        get :accept, params: params, format: :json
        expect(game.reload.pending).to be true
      end
    end

    context 'when the player has an account' do
      let(:email) { Faker::Internet.email }
      let(:password) { 'password' }
      let(:first_name) { Faker::Name.first_name }
      let(:last_name) { Faker::Name.last_name }
      let(:token) { 'token' }

      let!(:user) do
        User.create(email: email,
                    password: password,
                    firstName: first_name,
                    lastName: last_name,
                    approved: true,
                    token: token)
      end

      let!(:challengedUser) do
        User.create(email: 'bob@example.com',
                    password: 'password',
                    firstName: 'bob',
                    lastName: 'jones',
                    approved: true,
                    token: 'other_token')
      end

      context 'when the player\'s email matches the game\'s challenged_email' do
        let(:game) { user.games.create(challenged_email: challengedUser.email) }

        it 'sets the pending attribute on the game to false' do
          game.users << challengedUser
          params = { game_id: game.id, token: challengedUser.token }

          get :accept, params: params, format: :json
          expect(response.status).to eq 204
          expect(game.reload.pending).to be false
          expect(game.challenged_email).to eq challengedUser.email
        end
      end

      context 'when the player\'s email does not match the game\'s challenged_email' do
        let(:game) { user.games.create }

        it 'raises a not found exception' do
          params = { game_id: game.id, token: challengedUser.token }

          expect{
            get :accept, params: params, format: :json
          }.to raise_exception(ActiveRecord::RecordNotFound)

          expect(game.reload.pending).to be true
        end
      end
    end
  end
end
