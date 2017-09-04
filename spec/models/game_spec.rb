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

      it 'sets the player_color on the game' do
        user = User.create(
          email: email,
          password: password,
          firstName: first_name,
          lastName: last_name
        )

        game_params = {
          challengePlayer: true,
          challengedEmail: Faker::Internet.email,
          playerColor: 'white'
        }

        game = Game.create
        game.setup(user, game_params)

        expect(game.player_color).to eq 'white'
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

  describe '#current_player_color' do
    context 'when the player is the challenger' do
      let(:firstName) { Faker::Name.first_name }
      let(:lastName) { Faker::Name.last_name }
      let(:email) { Faker::Internet.email }
      let(:password) { 'password' }

      it 'returns the the color of the the challenger' do
        challenged_email = Faker::Internet.email
        user = User.create(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password
        )

        game = Game.create(challenged_email: challenged_email, player_color: 'black')
        expect(game.current_player_color(user.email)).to eq 'black'
      end
    end

    context 'when the player is not the challenger; (palyer is the challenged)' do
      let(:firstName) { Faker::Name.first_name }
      let(:lastName) { Faker::Name.last_name }
      let(:email) { Faker::Internet.email }
      let(:password) { 'password' }

      it 'returns the color of the player that is the challenged' do
        challenged_email = Faker::Internet.email
        user = User.create(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password
        )

        game = Game.create(challenged_email: email, player_color: 'black')
        expect(game.current_player_color(user.email)).to eq 'white'
      end
    end
  end

  describe '#serialize_games' do
    xit 'serializes the passed in games' do
    end
  end

  describe '#serialize_game' do
    it 'serializes a game instance' do
      user = User.create(
        firstName: Faker::Name.first_name,
        lastName: Faker::Name.last_name,
        email: Faker::Internet.email,
        password: 'password'
      )

      challenged_email = Faker::Internet.email

      game = Game.create(
        challenged_email: challenged_email,
        player_color: 'black'
      )
      game.pieces.create(
        pieceType: 'pawn',
        currentPosition: 'a2',
        color: 'black'
      )

      result = {
        type: 'game',
        id: game.id,
        attributes: {
          pending: game.pending,
          playerColor: 'black'
        },
        included: [game.pieces.first.serialize_piece]
      }

      expect(game.serialize_game(user.email)).to eq result
    end
  end

  describe '#handle_game_creation' do
    xit 'test' do
    end
  end

  describe '#handle_challenge' do
    context 'when a challenge is already in progress' do
      xit 'returns an error message' do
      end
    end

    context 'when a challenge has not been submitted' do
      xit 'test' do
      end
    end
  end
end
