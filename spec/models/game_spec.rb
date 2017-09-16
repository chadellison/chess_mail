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

    game = Game.create(
      human: true,
      challengedEmail: Faker::Internet.email,
      challengedName: Faker::Name.name,
      challengerColor: 'white'
    )

    game.users << user

    expect(game.users).to eq [user]
  end

  it 'has many pieces' do
    piece = Piece.create(
      pieceType: 'rook',
      color: 'black',
      currentPosition: 'a2'
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

        game = Game.create(
          human: true,
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white'
        )

        expect_any_instance_of(Game).to receive(:add_challenged_player)
        game.setup(user)
      end

      it 'calls send_challenge_email' do
        user = User.create(
          email: email,
          password: password,
          firstName: first_name,
          lastName: last_name
        )

        game = Game.create(
          human: true,
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white'
        )

        expect_any_instance_of(Game).to receive(:send_challenge_email).with(user)
        game.setup(user)
      end

      it 'sets the player_color on the game' do
        user = User.create(
          email: email,
          password: password,
          firstName: first_name,
          lastName: last_name
        )

        game = Game.create(
          human: true,
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white'
        )

        game.setup(user)

        expect(game.challengerColor).to eq 'white'
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

        game = Game.create(
          human: true,
          challengedEmail: user.email,
          challengedName: user.firstName,
          challengerColor: 'white'
        )
        expect{ game.add_challenged_player }.to change{ game.users.count }.by(1)
        expect(game.users.last).to eq user
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

        game = Game.create(
          human: true,
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white'
        )
        expect{ game.add_challenged_player }.not_to change{ game.users.count }
      end
    end
  end

  describe '#current_player_color' do
    context 'when the player is the challenger' do
      let(:firstName) { Faker::Name.first_name }
      let(:lastName) { Faker::Name.last_name }
      let(:email) { Faker::Internet.email }
      let(:password) { 'password' }

      it 'returns the color of the the challenger' do
        challengedEmail = Faker::Internet.email
        challengedName = Faker::Name.name

        user = User.create(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password
        )

        game = Game.create(
          challengedEmail: challengedEmail,
          challengerColor: 'black',
          challengedName: challengedName
        )
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

        game = Game.create(
          challengedEmail: user.email,
          challengerColor: 'black',
          challengedName: user.firstName
        )
        expect(game.current_player_color(user.email)).to eq 'white'
      end
    end
  end

  describe '#current_opponent_name' do
    context 'when the player is the challenger' do
      let(:firstName) { Faker::Name.first_name }
      let(:lastName) { Faker::Name.last_name }
      let(:email) { Faker::Internet.email }
      let(:password) { 'password' }

      it 'returns the first name of the challenged player' do
        challengedEmail = Faker::Internet.email
        challengedName = Faker::Name.name

        user = User.create(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password
        )

        game = Game.create(
          challengedEmail: challengedEmail,
          challengedName: challengedName,
          challengerColor: 'black'
        )
        expect(game.current_opponent_name(user.email)).to eq challengedName
      end
    end

    context 'when the user is not the challenger; (user is the challenged)' do
      let(:firstName) { Faker::Name.first_name }
      let(:lastName) { Faker::Name.last_name }
      let(:email) { Faker::Internet.email }
      let(:password) { 'password' }

      it 'returns the first name of the challenger' do
        user = User.create(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password
        )

        challenged_user = User.create(
          firstName: 'firstName',
          lastName: 'lastName',
          email: 'email',
          password: 'password'
        )

        game = user.games.create(
          challengedEmail: challenged_user.email,
          challengedName: challenged_user.firstName,
          challengerColor: 'black'
        )
        expect(game.current_opponent_name(challenged_user.email)).to eq user.firstName
      end
    end
  end

  describe '#current_opponent_email' do
    xit 'test' do
    end
  end

  describe '#is_challenger?' do
    xit 'test' do
    end
  end

  describe '#serialize_games' do
    it 'calls serialize game on each game' do
      user_email = Faker::Internet.email
      user_name = Faker::Name.name

      game = Game.create(
        human: true,
        challengedEmail:  user_email,
        challengedName: user_name,
        challengerColor: 'white'
      )

      expect_any_instance_of(Game).to receive(:serialize_game).with(user_email)
      games = [game]

      Game.serialize_games(games, user_email)
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

      challengedEmail = Faker::Internet.email
      challengedName = Faker::Name.name

      game = Game.create(
        challengedEmail: challengedEmail,
        challengedName: challengedName,
        challengerColor: 'black'
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
          playerColor: 'black',
          opponentName: challengedName,
          opponentGravatar: Digest::MD5.hexdigest(challengedEmail.downcase.strip),
          isChallenger: true,
          outcome: nil
        },
        included: [game.pieces.first.serialize_piece]
      }

      expect(game.serialize_game(user.email)).to eq result
    end
  end

  describe '#handle_resign' do
    xit 'test' do
    end
  end
end
