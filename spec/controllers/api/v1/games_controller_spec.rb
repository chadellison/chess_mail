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

    let!(:game1) do
      user.games.create(
        challengedEmail: 'abc@example.com',
        challengedName: Faker::Name.name,
        challengerColor: 'white'
      )
    end
    let!(:game2) do
      user.games.create(
        challengedEmail: '123@example.com',
        challengedName: Faker::Name.name,
        challengerColor: 'white'
      )
    end

    it 'returns all of that users\'s games' do
      get :index, params: { token: user.token }, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body).deep_symbolize_keys[:data].last[:id])
        .to eq game1.id
      expect(JSON.parse(response.body).deep_symbolize_keys[:data].first[:id])
        .to eq game2.id
    end

    context 'when the user has more than 6 games' do
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

      before do
        10.times do |n|
          user.games.create(
            challengedEmail: 'abc@example.com',
            challengedName: n.to_s,
            challengerColor: 'white'
          )
        end
      end

      it 'returns the most recent six' do
        expected = ['9', '8', '7', '6', '5', '4']
        get :index, params: { token: user.token }, format: :json
        actual = JSON.parse(response.body).deep_symbolize_keys[:data]
                     .map { |game| game[:attributes][:opponentName] }

        expect(actual).to eq expected
      end
    end

    context 'when the user has more than six games and passes in a page param' do
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

      before do
        user.games.destroy_all

        10.times do |n|
          user.games.create(
            challengedEmail: 'abc@example.com',
            challengedName: n.to_s,
            challengerColor: 'white'
          )
        end
      end

      it 'returns the first 4 games created' do
        expected = ['3', '2', '1', '0']
        get :index, params: { token: user.token, page: 2 }, format: :json
        actual = JSON.parse(response.body).deep_symbolize_keys[:data]
                     .map { |game| game[:attributes][:opponentName] }

        expect(actual).to eq expected
      end
    end
  end

  describe '#show' do
    context 'when the game exists' do
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

      let!(:game) do
        user.games.create(
          challengedEmail: 'abc@example.com',
          challengedName: Faker::Name.name,
          challengerColor: 'white',
          human: true
        )
      end

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

      it 'returns a 404' do
        expect{
          get :show, params: { id: Faker::Number.number(4), token: user.token }, format: :json
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

        let!(:challengedUser) {
          User.create(
            email: 'bob@example.com',
            password: 'password',
            firstName: 'bob',
            lastName: 'jones',
            approved: true,
            token: 'other_token'
            )
        }

        let(:game_params) do
          {
            game: {
              challengedName: challengedUser.firstName,
              challengedEmail: challengedUser.email,
              challengerColor: 'white',
              human: true
            },
            token: user.token
          }
        end

        it 'creates and returns the game' do
          expect {
            post :create, params: game_params, format: :json
          }.to change { user.games.count }.by(1)

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

            expect(Game.find(game_id).challengedEmail).to eq challengedUser.email
          end
        end

        context 'when the challenged player does not have an account' do
          let(:challengedEmail) { Faker::Internet.email }
          let(:challengedName) { Faker::Name.first_name }

          let(:params) do
            {
              game: {
                challengedName: challengedName,
                challengedEmail: challengedEmail,
                challengerColor: 'white',
                challengePlayer: true,
                challengeRobot: false
              },
              token: user.token
            }
          end

          it 'sets the challenged user\'s email on the game' do
            post :create, params: params, format: :json
            game_id = JSON.parse(response.body)['data']['id']

            expect(Game.find(game_id).challengedEmail).to eq challengedEmail
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
        let(:challengedEmail) { Faker::Internet.email }

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

        let(:game_params) do
          {
            game: {
              challengedName: '',
              challengedEmail: challengedEmail,
              challengerColor: 'white',
              challengePlayer: true,
              challengeRobot: false
            },
            token: user.token
          }
        end

        it 'does not create a game' do
          expect{
            post :create, params: game_params, format: :json
          }.not_to change{ Game.count }
        end

        it 'returns a json api error message' do
          error = 'challengedName can\'t be blank'
          post :create, params: game_params, format: :json

          expect(response.status).to eq 400
          expect(JSON.parse(response.body)['errors']).to eq error
        end
      end

      context 'when no email is passed in' do
        let(:challengedName) { Faker::Name.first_name }

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
              challengedName: challengedName,
              challengedEmail: '',
              challengerColor: 'white',
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
          error = 'challengedEmail can\'t be blank'
          post :create, params: game_params, format: :json

          expect(response.status).to eq 400
          expect(JSON.parse(response.body)['errors']).to eq error
        end
      end

      context 'when the email passed in is the same as the player who is submitting the challenge' do
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

        let(:game_params) do
          {
            game: {
              challengedName: 'same user',
              challengedEmail: user.email,
              challengerColor: 'white',
              challengePlayer: true,
              challengeRobot: false
            },
            token: user.token
          }
        end

        it 'does not create a game' do
          expect {
            post :create, params: game_params, format: :json
          }.not_to change { Game.count }
        end

        it 'returns a json api error message' do
          error = 'Your opponent must be someone other than yourself.'
          post :create, params: game_params, format: :json

          expect(response.status).to eq 400
          expect(JSON.parse(response.body)['errors']).to eq error
        end
      end
    end

    context 'against an AI player' do
      context 'with valid parameters' do
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

        let!(:challengedUser) do
          User.create(
            email: 'bob@example.com',
            password: 'password',
            firstName: 'bob',
            lastName: 'jones',
            approved: true,
            token: 'other_token'
          )
        end

        let(:game_params) do
          {
            game: {
              challengedName: 'robot',
              challengedEmail: 'robot',
              challengerColor: 'white',
              human: false
            },
            token: user.token
          }
        end

        it 'creates and returns the game' do
          expect { post :create, params: game_params, format: :json }
            .to change { user.games.count }.by(1)

          expect(response.status).to eq 201
          expect(JSON.parse(response.body)['data']['type']).to eq 'game'
          expect(JSON.parse(response.body)['data']['attributes']['pending'])
            .to be false
        end
      end
    end
  end

  describe '#destroy' do
    context 'when the player is not authenticated' do
      it 'raises a record not found error' do
        user = User.new
        params = { id: Faker::Number.number(4), token: user.token }

        expect { delete :destroy, params: params, format: :json }
          .to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the game cannot be found' do
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

      it 'raises a record not found error' do
        params = { id: Faker::Number.number(4), token: user.token }

        expect { delete :destroy, params: params, format: :json }
          .to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the game is pending' do
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

      let!(:challengedUser) do
        User.create(
          email: 'bob@example.com',
          password: 'password',
          firstName: 'bob',
          lastName: 'jones',
          approved: true,
          token: 'other_token'
        )
      end

      let(:game) do
        user.games.create(
          challengedEmail: challengedUser.email,
          challengedName: challengedUser.firstName,
          challengerColor: 'white'
        )
      end

      it 'deletes the game' do
        params = { id: game.id, token: user.token }

        expect { delete :destroy, params: params, format: :json }
          .to change { Game.count }.by(-1)

        expect(response.status).to eq 204
      end
    end

    context 'when the game outcome is complete' do
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

      let!(:challengedUser) do
        User.create(
          email: 'bob@example.com',
          password: 'password',
          firstName: 'bob',
          lastName: 'jones',
          approved: true,
          token: 'other_token'
        )
      end

      let(:game) do
        user.games.create(
          challengedEmail: challengedUser.email,
          challengedName: challengedUser.firstName,
          challengerColor: 'white',
          pending: false,
          outcome: 'draw!'
        )
      end

      it 'archives the game for the current user' do
        params = { id: game.id, token: user.token }

        expect {
          delete :destroy, params: params, format: :json
        }.to change { user.archives.count }.by(1)

        expect(user.archives.last.game_id).to eq game.id
        expect(game.reload.outcome).to eq 'draw!'
        expect(response.status).to eq 204
      end

      it 'does not archive the game for the other user' do
        params = { id: game.id, token: user.token }

        expect {
          delete :destroy, params: params, format: :json
        }.not_to change { challengedUser.archives.count }
      end
    end
  end
end
