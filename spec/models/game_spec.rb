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

  it 'has many moves' do
    game = Game.create
    move = Move.create(
      pieceType: 'rook',
      color: 'black',
      currentPosition: 'a2'
    )

    game.moves << move

    expect(game.moves).to eq [move]
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
    let(:firstName) { Faker::Name.first_name }
    let(:lastName) { Faker::Name.last_name }
    let(:email) { Faker::Internet.email }
    let(:password) { 'password' }

    let(:user) do
      User.create(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password
      )
    end

    let(:challenged_user) do
      User.create(
        firstName: 'firstName',
        lastName: 'lastName',
        email: 'email',
        password: 'password'
      )
    end

    let(:game) do
      user.games.create(
        challengedEmail: challenged_user.email,
        challengedName: challenged_user.firstName,
        challengerColor: 'black'
      )
    end

    context 'when the challenged email is the user email' do
      it 'returns the game\'s email that is not the challengedEmail' do
        expect(game.current_opponent_email(challenged_user.email)).to eq user.email
      end
    end

    context 'when the challenged email is not the user email' do
      it 'returns the challengedEmail' do
        expect(game.current_opponent_email(user.email)).to eq challenged_user.email
      end
    end
  end

  describe '#challenger?' do
    let(:firstName) { Faker::Name.first_name }
    let(:lastName) { Faker::Name.last_name }
    let(:email) { Faker::Internet.email }
    let(:password) { 'password' }

    let(:user) do
      User.create(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password
      )
    end

    let(:challenged_user) do
      User.create(
        firstName: 'firstName',
        lastName: 'lastName',
        email: 'email',
        password: 'password'
      )
    end

    let(:game) do
      user.games.create(
        challengedEmail: challenged_user.email,
        challengedName: challenged_user.firstName,
        challengerColor: 'black'
      )
    end

    context 'when email belongs to the challenger' do
      it 'returns true' do
        expect(game.challenger?(email)).to be true
      end
    end

    context 'when email does not belong to the challenger' do
      it 'returns false' do
        expect(game.challenger?(challenged_user.email)).to be false
      end
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

      result = {
        type: 'game',
        id: game.id,
        attributes: {
          pending: game.pending,
          playerColor: 'black',
          opponentName: challengedName,
          opponentGravatar: Digest::MD5.hexdigest(challengedEmail.downcase.strip),
          isChallenger: true,
          outcome: nil,
          human: true
        },
        included: []
      }

      expect(game.serialize_game(user.email)).to eq result
    end
  end

  describe '#handle_resign' do
    let(:firstName) { Faker::Name.first_name }
    let(:lastName) { Faker::Name.last_name }
    let(:email) { Faker::Internet.email }
    let(:password) { 'password' }

    let(:user) do
      User.create(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password
      )
    end

    let(:challenged_user) do
      User.create(
        firstName: 'firstName',
        lastName: 'lastName',
        email: 'email',
        password: 'password'
      )
    end

    let(:game) do
      user.games.create(
        challengedEmail: challenged_user.email,
        challengedName: challenged_user.firstName,
        challengerColor: 'white'
      )
    end

    context 'when the current player is white' do
      it 'updates the game so that black wins' do
        game.handle_resign(user)
        expect(game.outcome).to eq 'black wins!'
      end
    end

    context 'when the current player is black' do
      it 'updates the game so that white wins' do
        game.handle_resign(challenged_user)
        expect(game.outcome).to eq 'white wins!'
      end
    end
  end

  describe '#handle_move' do
    context 'when a piece is on the square being moved to' do
      let(:user) do
        User.create(
          firstName: Faker::Name.first_name,
          lastName: Faker::Name.last_name,
          email: Faker::Internet.email,
          password: 'password'
        )
      end

      let(:game) do
        Game.create(
          challengedEmail: Faker::Name.name,
          challengedName: Faker::Internet.email,
          challengerColor: 'white'
        )
      end

      before do
        game.pieces.find_by(startIndex: 20).update(currentPosition: 'd4')
        game.pieces.find_by(startIndex: 13).update(currentPosition: 'e5')
      end

      it 'removes that piece from the game' do
        move_params = { currentPosition: 'e5', startIndex: '20', pieceType: 'pawn' }
        expect { game.handle_move(move_params, user) }.to change {
          game.pieces.count }.by(-1)

        expect(game.pieces.find_by(startIndex: 13)).to be_nil
      end

      it 'places the new piece on the square' do
        move_params = { currentPosition: 'e5', startIndex: '20', pieceType: 'pawn' }
        game.handle_move(move_params, user)
        expect(game.pieces.find_by(startIndex: 20).currentPosition).to eq 'e5'
      end
    end

    context 'when the move is an en passant' do
      let(:user) do
        User.create(
          firstName: Faker::Name.first_name,
          lastName: Faker::Name.last_name,
          email: Faker::Internet.email,
          password: 'password'
        )
      end

      let(:game) do
        Game.create(
          challengedEmail: Faker::Name.name,
          challengedName: Faker::Internet.email,
          challengerColor: 'white'
        )
      end

      before do
        game.pieces.find_by(startIndex: 20).update(currentPosition: 'd4', movedTwo: true)
        game.pieces.find_by(startIndex: 13).update(currentPosition: 'e4')
      end

      it 'removes the opponent pawn from the adjacent position' do
        move_params = { currentPosition: 'd3', startIndex: '13', pieceType: 'pawn' }
        expect { game.handle_move(move_params, user) }.to change {
          game.pieces.count }.by(-1)

        expect(game.pieces.find_by(currentPosition: 'd4')).to be_nil
      end

      it 'places the new piece on the square' do
        move_params = { currentPosition: 'd3', startIndex: '13', pieceType: 'pawn' }
        game.handle_move(move_params, user)
        expect(game.pieces.find_by(startIndex: 13).currentPosition).to eq 'd3'
      end
    end

    context 'when a pawn moves two' do
      let(:user) do
        User.create(
          firstName: Faker::Name.first_name,
          lastName: Faker::Name.last_name,
          email: Faker::Internet.email,
          password: 'password'
        )
      end

      let(:game) do
        Game.create(
          challengedEmail: Faker::Name.name,
          challengedName: Faker::Internet.email,
          challengerColor: 'white'
        )
      end

      it 'updates the movedTwo property to true' do
        move_params = { currentPosition: 'd4', startIndex: 20, pieceType: 'pawn' }
        game.handle_move(move_params, user)

        expect(game.pieces.find_by(startIndex: 20).movedTwo).to be true
      end
    end

    context 'when a pawn does not move two it updates the movedTwo property to false' do
      let(:user) do
        User.create(
          firstName: Faker::Name.first_name,
          lastName: Faker::Name.last_name,
          email: Faker::Internet.email,
          password: 'password'
        )
      end

      let(:game) do
        Game.create(
          challengedEmail: Faker::Name.name,
          challengedName: Faker::Internet.email,
          challengerColor: 'white'
        )
      end

      it 'updates the movedTwo property to true' do
        move_params = { currentPosition: 'd3', startIndex: 20, pieceType: 'pawn' }
        game.handle_move(move_params, user)

        expect(game.pieces.find_by(startIndex: 20).movedTwo).to be false
      end
    end

    context 'when the move is a castle' do
      let(:user) do
        User.create(
          firstName: Faker::Name.first_name,
          lastName: Faker::Name.last_name,
          email: Faker::Internet.email,
          password: 'password'
        )
      end

      let(:game) do
        Game.create(
          challengedEmail: Faker::Name.name,
          challengedName: Faker::Internet.email,
          challengerColor: 'white'
        )
      end

      before do
        game.pieces.where(currentPosition: ['f1', 'g1']).destroy_all
      end

      it 'updates the position of the rook as well' do
        move_params = { currentPosition: 'g1', startIndex: 29, pieceType: 'king' }
        game.handle_move(move_params, user)
        expect(game.pieces.find_by(startIndex: 32).currentPosition).to eq 'f1'
      end
    end

    context 'when the move is a castle on the queen side' do
      let(:user) do
        User.create(
          firstName: Faker::Name.first_name,
          lastName: Faker::Name.last_name,
          email: Faker::Internet.email,
          password: 'password'
        )
      end

      let(:game) do
        Game.create(
          challengedEmail: Faker::Name.name,
          challengedName: Faker::Internet.email,
          challengerColor: 'white'
        )
      end

      before do
        game.pieces.where(currentPosition: ['d1', 'c1', 'b1']).destroy_all
      end

      it 'updates the position of the rook as well' do
        move_params = { currentPosition: 'c1', startIndex: 29, pieceType: 'king' }
        game.handle_move(move_params, user)

        expect(game.pieces.find_by(startIndex: 25).currentPosition).to eq 'd1'
      end
    end

    context 'when the move is a castle on the queen side for a black piece' do
      let(:user) do
        User.create(
          firstName: Faker::Name.first_name,
          lastName: Faker::Name.last_name,
          email: Faker::Internet.email,
          password: 'password'
        )
      end

      let(:game) do
        Game.create(
          challengedEmail: Faker::Name.name,
          challengedName: Faker::Internet.email,
          challengerColor: 'white'
        )
      end

      before do
        game.pieces.where(currentPosition: ['d8', 'c8', 'b8']).destroy_all
      end

      it 'updates the position of the rook as well' do
        move_params = { currentPosition: 'c8', startIndex: 5, pieceType: 'king' }
        game.handle_move(move_params, user)

        expect(game.pieces.find_by(startIndex: 1).currentPosition).to eq 'd8'
      end
    end

    context 'when a pawn moves crosses to the end side and selects a queen' do
      xit 'test' do
      end
    end

    context 'when a pawn does not move to the other side and tries to select a queen' do
      xit 'test' do
      end
    end
  end

  describe '#move' do
    xit 'test' do
    end
  end

  describe '#current_turn' do
    xit 'test' do
    end
  end

  describe '#piece_type_from_notation' do
    xit 'test' do
    end
  end

  describe '#position_from_notation' do
    xit 'test' do
    end
  end

  describe '#retrieve_start_index' do
    xit 'test' do
    end
  end

  describe '#find_current_location' do
    xit 'test' do
    end
  end

  describe '#create_piece_from_notation' do
    context 'when the notation is e4 on white\'s turn' do
      xit 'creates a piece on the game with a currentPosition of e4' do
        game = Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )

        expect { game.create_piece_from_notation('e4') }
          .to change { game.pieces.count }.by(1)

        expect(game.pieces.last.currentPosition)
          .to eq 'e4'

        expect(game.pieces.last.color)
          .to eq 'white'

        expect(game.pieces.last.pieceType)
          .to eq 'pawn'
      end
    end

    context 'when the notation is Bb5 on white\'s turn' do
      xit 'creates a piece on the game with a currentPosition of e4' do
        game = Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )

        expect { game.create_piece_from_notation('Bb5') }
          .to change { game.pieces.count }.by(1)

        expect(game.pieces.last.currentPosition)
          .to eq 'b5'

        expect(game.pieces.last.color)
          .to eq 'white'

        expect(game.pieces.last.pieceType)
          .to eq 'bishop'
      end
    end

    context 'when the notation is Nb6 on white\'s turn' do
      xit 'creates a piece on the game with a currentPosition of e4' do
        game = Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )

        expect { game.create_piece_from_notation('Nb6') }
          .to change { game.pieces.count }.by(1)

        expect(game.pieces.last.currentPosition)
          .to eq 'b6'

        expect(game.pieces.last.color)
          .to eq 'white'

        expect(game.pieces.last.pieceType)
          .to eq 'knight'
      end
    end

    context 'when the notation is Kd8 on white\'s turn' do
      xit 'creates a piece on the game with a currentPosition of e4' do
        game = Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )

        expect { game.create_piece_from_notation('Kd8') }
          .to change { game.pieces.count }.by(1)

        expect(game.pieces.last.currentPosition)
          .to eq 'd8'

        expect(game.pieces.last.color)
          .to eq 'white'

        expect(game.pieces.last.pieceType)
          .to eq 'king'
      end
    end

    context 'when the notation is Qa1 on white\'s turn' do
      xit 'creates a piece on the game with a currentPosition of e4' do
        game = Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )

        expect { game.create_piece_from_notation('Qa1') }
          .to change { game.pieces.count }.by(1)

        expect(game.pieces.last.currentPosition)
          .to eq 'a1'

        expect(game.pieces.last.color)
          .to eq 'white'

        expect(game.pieces.last.pieceType)
          .to eq 'queen'
      end
    end

    context 'when the notation is Rd2 on white\'s turn' do
      xit 'creates a piece on the game with a currentPosition of e4' do
        game = Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )

        expect { game.create_piece_from_notation('Rd2') }
          .to change { game.pieces.count }.by(1)

        expect(game.pieces.last.currentPosition)
          .to eq 'd2'

        expect(game.pieces.last.color)
          .to eq 'white'

        expect(game.pieces.last.pieceType)
          .to eq 'rook'
      end
    end

    context 'when the notation is O-O on white\'s turn' do
      xit 'creates a piece on the gam with a currentPosition of e4' do
        game = Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )

        expect { game.create_piece_from_notation('O-O') }
          .to change { game.pieces.count }.by(1)

        expect(game.pieces.last.currentPosition)
          .to eq 'g1'

        expect(game.pieces.last.color)
          .to eq 'white'

        expect(game.pieces.last.pieceType)
          .to eq 'king'
      end
    end

    context 'when the notation is O-O on black\'s turn' do
      xit 'creates a piece on the game with a currentPosition of e4' do
        game = Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )

        game.pieces.create(
          currentPosition: 'd4',
          color: 'white',
          pieceType: 'black',
          startIndex: '20'
        )

        expect { game.create_piece_from_notation('O-O') }
          .to change { game.pieces.count }.by(1)

        expect(game.pieces.last.currentPosition)
          .to eq 'g8'

        expect(game.pieces.last.color)
          .to eq 'black'

        expect(game.pieces.last.pieceType)
          .to eq 'king'
      end
    end

    context 'when the notation is O-O-O on white\'s turn' do
      xit 'creates a piece on the game with a currentPosition of e4' do
        game = Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )

        expect { game.create_piece_from_notation('O-O-O') }
          .to change { game.pieces.count }.by(1)

        expect(game.pieces.last.currentPosition)
          .to eq 'c1'

        expect(game.pieces.last.color)
          .to eq 'white'

        expect(game.pieces.last.pieceType)
          .to eq 'king'
      end
    end

    context 'when the notation is O-O-O on black\'s turn' do
      xit 'creates a piece on the game with a currentPosition of c8' do
        game = Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )

        game.pieces.create(
          currentPosition: 'd4',
          color: 'white',
          pieceType: 'black',
          startIndex: '20'
        )

        expect { game.create_piece_from_notation('O-O-O') }
          .to change { game.pieces.count }.by(1)

        expect(game.pieces.last.currentPosition)
          .to eq 'c8'

        expect(game.pieces.last.color)
          .to eq 'black'

        expect(game.pieces.last.pieceType)
          .to eq 'king'
      end
    end

    context 'when the notation is Nxf7 on black\'s turn' do
      xit 'creates a piece on the game with a currentPosition of f7' do
        game = Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )

        game.pieces.create(
          currentPosition: 'd4',
          color: 'white',
          pieceType: 'black',
          startIndex: '20'
        )

        expect { game.create_piece_from_notation('Nxf7') }
          .to change { game.pieces.count }.by(1)

        expect(game.pieces.last.currentPosition)
          .to eq 'f7'

        expect(game.pieces.last.color)
          .to eq 'black'

        expect(game.pieces.last.pieceType)
          .to eq 'knight'
      end
    end

    context 'when the notation is Nxf7 on black\'s turn' do
      xit 'creates a piece on the game with a currentPosition of f7' do
        game = Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )

        game.pieces.create(
          currentPosition: 'd4',
          color: 'white',
          pieceType: 'black',
          startIndex: '20'
        )

        expect { game.create_piece_from_notation('Nxf7') }
          .to change { game.pieces.count }.by(1)

        expect(game.pieces.last.currentPosition)
          .to eq 'f7'

        expect(game.pieces.last.color)
          .to eq 'black'

        expect(game.pieces.last.pieceType)
          .to eq 'knight'
      end
    end

    context 'when the notation is R6e2 on black\'s turn' do
      xit 'creates a piece on the game with a currentPosition of e2' do
        game = Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )

        game.pieces.create(
          currentPosition: 'd4',
          color: 'white',
          pieceType: 'black',
          startIndex: '20'
        )

        expect { game.create_piece_from_notation('R6e2') }
          .to change { game.pieces.count }.by(1)

        expect(game.pieces.last.currentPosition)
          .to eq 'e2'

        expect(game.pieces.last.color)
          .to eq 'black'

        expect(game.pieces.last.pieceType)
          .to eq 'rook'
      end
    end

    context 'when the notation is Rdf8 on black\'s turn' do
      xit 'creates  a piece on the game with a currentPosition of f8' do
        game = Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )

        game.pieces.find_by(startIndex: 8).update(
          currentPosition: 'd4',
          color: 'white',
          pieceType: 'rook',
          hasMoved: true
        )

        expect { game.create_piece_from_notation('Rdf8') }
          .to change { game.pieces.count }.by(1)

        expect(game.pieces.find_by(startIndex: 8).currentPosition)
          .to eq 'f8'

        expect(game.pieces.find_by(startIndex: 8).color)
          .to eq 'black'

        expect(game.pieces.find_by(startIndex: 8).pieceType)
          .to eq 'rook'
      end
    end

    context 'when the notation is Rd5# on black\'s turn' do
      xit 'creates a piece on the game with a currentPosition of d5' do
        game = Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )

        game.pieces.create(
          currentPosition: 'd4',
          color: 'white',
          pieceType: 'rook',
          startIndex: '8'
        )

        expect { game.create_piece_from_notation('Rd5#') }
          .to change { game.pieces.count }.by(1)

        expect(game.pieces.last.currentPosition)
          .to eq 'd5'

        expect(game.pieces.last.color)
          .to eq 'black'

        expect(game.pieces.last.pieceType)
          .to eq 'rook'
      end
    end

    context 'when the notation is d5# on black\'s turn' do
      xit 'creates a piece on the game with a currentPosition of d5' do
        game = Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )

        game.pieces.create(
          currentPosition: 'd4',
          color: 'white',
          pieceType: 'rook',
          startIndex: '8'
        )

        expect { game.create_piece_from_notation('d5#') }
          .to change { game.pieces.count }.by(1)

        expect(game.pieces.last.currentPosition)
          .to eq 'd5'

        expect(game.pieces.last.color)
          .to eq 'black'

        expect(game.pieces.last.pieceType)
          .to eq 'pawn'
      end
    end

    context 'when the notation is f1=Q. on black\'s turn' do
      xit 'creates a piece on the game with a currentPosition of f1' do
        game = Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )

        game.pieces.create(
          currentPosition: 'd4',
          color: 'white',
          pieceType: 'rook',
          startIndex: '8'
        )

        expect { game.create_piece_from_notation('f1=Q') }
          .to change { game.pieces.count }.by(1)

        expect(game.pieces.last.currentPosition)
          .to eq 'f1'

        expect(game.pieces.last.color)
          .to eq 'black'

        expect(game.pieces.last.pieceType)
          .to eq 'queen'
      end
    end
  end

  describe '#add_pieces' do
    xit 'test' do
    end
  end

  describe '#find_start_position' do
    xit 'test' do
    end
  end

  describe '#handle_en_passant' do
    xit 'test' do
    end
  end

  describe '#en_passant?' do
    xit 'test' do
    end
  end

  describe '#handle_castle' do
    xit 'test' do
    end
  end

  describe '#create_move' do
    xit 'test' do
    end
  end

  describe '#handle_captured_piece' do
    context 'when there is a piece on the square' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )
      }

      let(:piece) {
        game.pieces.find_by(currentPosition: 'd2')
      }

      before do
        piece.update(currentPosition: 'd4')
        game.pieces.find_by(currentPosition: 'e7').update(currentPosition: 'e5')
      end

      it 'removes that piece from the game' do
        move_params = { currentPosition: "d5", startIndex: 12, hasMoved: true }
        expect(game.handle_captured_piece(move_params, piece))
      end
    end
  end

  describe '#crossed_pawn?' do
    xit 'test' do
    end
  end

  describe '#valid_piece_type?' do
    xit 'test' do
    end
  end
end
