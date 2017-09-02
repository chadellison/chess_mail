require 'rails_helper'

RSpec.describe Game, type: :model do
  let(:email) { Faker::Internet.email }
  let(:password) { 'password' }
  let(:first_name) { Faker::Name.first_name }
  let(:last_name) { Faker::Name.last_name }

  it 'has many users' do
    user = User.create(
      email: email,
      password: password,
      firstName: first_name,
      lastName: last_name
    )

    game = Game.create
    game.users << user

    expect(game.users).to eq [user]
  end

  it 'has many pieces' do
    piece = Piece.create(
      pieceType: 'rook',
      color: 'black',
      currentPosition: 'a2',
    )

    game = Game.create
    game.pieces << piece

    expect(game.pieces).to eq [piece]
  end

  describe '#setup' do
    context 'when the game_params have challengePlayer equal to true' do
      it 'calls add_challenged_player' do
        user = User.create(
          email: email,
          password: password,
          firstName: first_name,
          lastName: last_name
        )

        game_params = {
          challengePlayer: true,
          challengedEmail: Faker::Internet.email
        }

        game = Game.create

        expect_any_instance_of(Game).to receive(:add_challenged_player).with(game_params[:challengedEmail])
        game.setup(user, game_params)
      end

      it 'calls send_challenge_email' do
        user = User.create(
          email: email,
          password: password,
          firstName: first_name,
          lastName: last_name
        )

        game_params = {
          challengePlayer: true,
          challengedEmail: Faker::Internet.email
        }

        game = Game.create

        expect_any_instance_of(Game).to receive(:send_challenge_email)
            .with(user, game_params)
        game.setup(user, game_params)
      end
    end
  end

  describe '#add_challenged_player' do
    context 'when the user has an account' do
      let(:email) { Faker::Internet.email }
      let(:password) { 'password' }
      let(:first_name) { Faker::Name.first_name }
      let(:last_name) { Faker::Name.last_name }

      it 'adds a player to the game by email' do
        user = User.create(
          email: email,
          password: password,
          firstName: first_name,
          lastName: last_name
        )

        game = Game.create
        expect{ game.add_challenged_player(user.email) }.to change{ game.users.count }.by(1)
        expect(game.users.last).to eq user
      end

      it 'sets the challenged_id on the game to the user\'s id' do
        user = User.create(
          email: email,
          password: password,
          firstName: first_name,
          lastName: last_name
        )

        game = Game.create
        game.add_challenged_player(user.email)

        expect(game.challenged_email).to eq user.email
      end
    end

    context 'when the user does not have an account' do
      let(:email) { Faker::Internet.email }
      let(:password) { 'password' }
      let(:first_name) { Faker::Name.first_name }
      let(:last_name) { Faker::Name.last_name }

      it 'does not add the player to the game' do
        user = User.new(
          email: email,
          password: password,
          firstName: first_name,
          lastName: last_name
        )

        game = Game.create
        expect{ game.add_challenged_player(user.email) }.not_to change{ game.users.count }
      end
    end
  end

  describe '#serialize_games' do
    xit 'serializes the passed in games' do
    end
  end

  describe '#serialize_game' do
    xit 'serializes a game instance' do
    end
  end

  describe '#handle_game_creation' do
    xit 'test' do
    end
  end

  describe '#handle_challenge' do
    xit 'test' do
    end
  end
end
