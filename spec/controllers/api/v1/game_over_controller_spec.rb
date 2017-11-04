require 'rails_helper'

RSpec.describe Api::V1::GameOverController, type: :controller do
  describe '#update' do
    context 'when the player is not authenticated' do
      it 'raises a record not found error' do
        user = User.new
        params = { id: Faker::Number.number(4), token: user.token }

        expect { patch :update, params: params, format: :json }
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

        expect { patch :update, params: params, format: :json }
          .to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    context 'when a player checkmates another player' do
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
          pending: false
        )
      end

      it 'updates the outcome of a game to the winning player\'s color' do
        params = { id: game.id, outcome: 'white wins', token: user.token }

        patch :update, params: params, format: :json

        expect(game.reload.outcome).to eq 'white wins'
        expect(response.status).to eq 201
        expect(JSON.parse(response.body)['data']['id']).to eq game.id
      end
    end

    context 'when the game is a draw' do
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

      it 'updates the outcome of a game to draw' do
        params = { id: game.id, outcome: 'draw', token: user.token }

        patch :update, params: params, format: :json

        expect(game.reload.outcome).to eq 'draw'
        expect(response.status).to eq 201
        expect(JSON.parse(response.body)['data']['id']).to eq game.id
      end
    end

    context 'when the resign parameter is present' do
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
          pending: false
        )
      end

      it 'sets the game outcome to the opponent color as the winner' do
        params = { id: game.id, resign: true, token: user.token }
        opponent_color = 'black'

        patch :update, params: params, format: :json

        expect(response.status).to eq 201
        expect(game.reload.outcome).to eq opponent_color + ' wins'
        expect(JSON.parse(response.body)['data']['id']).to eq game.id
      end
    end
  end
end
