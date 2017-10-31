require 'rails_helper'

RSpec.describe Api::V1::AcceptChallengeController, type: :controller do
  describe '#show' do
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

      let(:game) do
        user.games.create(
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white'
        )
      end

      it 'does not set the pending attribute on the game to false' do
        bad_token = 'bad_token'
        params = { id: game.id, token: bad_token }

        get :show, params: params, format: :json
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

      context 'when the player\'s email matches the game\'s challengedEmail' do
        let(:game) do
          user.games.create(
            challengedEmail: challengedUser.email,
            challengedName: challengedUser.firstName,
            challengerColor: 'white'
          )
        end

        it 'sets the pending attribute on the game to false' do
          game.users << challengedUser
          params = { id: game.id, token: challengedUser.token }

          get :show, params: params, format: :json
          expect(response.status).to eq 204
          expect(game.reload.pending).to be false
          expect(game.challengedEmail).to eq challengedUser.email
        end
      end

      context 'when the player\'s email does not match the game\'s challengedEmail' do
        let(:game) do
          user.games.create(
            challengedEmail: Faker::Internet.email,
            challengedName: Faker::Name.name,
            challengerColor: 'whtie'
          )
        end

        it 'raises a not found exception' do
          params = { id: game.id, token: challengedUser.token }

          expect{
            get :show, params: params, format: :json
          }.to raise_exception(ActiveRecord::RecordNotFound)

          expect(game.reload.pending).to be true
        end
      end
    end

    context 'when the params include from_email' do
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

        let(:game) do
          user.games.create(
            challengedEmail: Faker::Internet.email,
            challengedName: Faker::Name.name,
            challengerColor: 'white'
          )
        end

        it 'does not set the pending attribute on the game to false' do
          ENV['host'] = 'host'
          bad_token = 'bad_token'
          params = { id: game.id, token: bad_token, from_email: true }

          get :show, params: params, format: :json
          expect(game.reload.pending).to be true
          expect(response.status).to eq 302
        end
      end

      context 'when the player has an account' do
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

        context 'when the player\'s email matches the game\'s challengedEmail' do
          let(:game) do
            user.games.create(
              challengedEmail: challengedUser.email,
              challengedName: challengedUser.firstName,
              challengerColor: 'white'
            )
          end

          it 'sets the pending attribute on the game to false' do
            ENV['host'] = 'host'
            game.users << challengedUser
            params = {
              id: game.id, token: challengedUser.token, from_email: true
            }

            get :show, params: params, format: :json

            expect(response.status).to eq 302
            expect(game.reload.pending).to be false
            expect(game.challengedEmail).to eq challengedUser.email
          end
        end

        context 'when the player\'s email does not match the game\'s challengedEmail' do
          let(:game) do
            user.games.create(
              challengedEmail: Faker::Internet.email,
              challengedName: Faker::Name.name,
              challengerColor: 'whtie'
            )
          end

          it 'raises a not found exception' do
            params = { id: game.id, token: challengedUser.token, from_email: true }

            expect{
              get :show, params: params, format: :json
            }.to raise_exception(ActiveRecord::RecordNotFound)

            expect(game.reload.pending).to be true
          end
        end
      end
    end
  end
end
