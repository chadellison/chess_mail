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
        game.reload.handle_move(move_params, user)
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
        game.reload.handle_move(move_params, user)

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
        game.reload.handle_move(move_params, user)

        expect(game.pieces.find_by(startIndex: 1).currentPosition).to eq 'd8'
      end
    end

    context 'when human is present' do
      let(:user) {
        User.create(
          email: Faker::Internet.email,
          password: 'password',
          firstName: Faker::Name.first_name,
          lastName: Faker::Name.last_name,
          token: 'token',
          hashed_email: 'hashed_email'
        )
      }

      let(:game) do
        user.games.create(
          challengedEmail: Faker::Name.name,
          challengedName: Faker::Internet.email,
          challengerColor: 'white',
          human: true
        )
      end

      let(:user_piece) {
        game.pieces.create(
          currentPosition: 'a7',
          pieceType: 'rook',
          color: 'black',
          startIndex: 5
        )
      }

      it 'calls move and send_new_move_email' do
        move_params = { currentPosition: 'a7', startIndex: 5, pieceType: 'king' }
        expect_any_instance_of(Game).to receive(:move).with(move_params)
        expect_any_instance_of(Game).to receive(:send_new_move_email)
        game.handle_move(move_params, user)
      end
    end

    context 'when human is not present' do
      let(:user) {
        User.create(
          email: Faker::Internet.email,
          password: 'password',
          firstName: Faker::Name.first_name,
          lastName: Faker::Name.last_name,
          token: 'token',
          hashed_email: 'hashed_email'
        )
      }

      let!(:game) do
        user.games.create(
          challengedEmail: Faker::Name.name,
          challengedName: Faker::Internet.email,
          challengerColor: 'white',
          human: false
        )
      end

      let(:user_piece) {
        game.pieces.create(
          currentPosition: 'a7',
          pieceType: 'rook',
          color: 'black',
          startIndex: 5
        )
      }
      it 'calls move twice' do
        move_params = { currentPosition: 'a7', startIndex: 5, pieceType: 'king' }
        expect_any_instance_of(Game).to receive(:move).twice
        game.handle_move(move_params, user)
      end
    end
  end

  describe '#move' do
    context 'when a move is not valid' do
      let(:game) do
        Game.create(
          challengedEmail: Faker::Name.name,
          challengedName: Faker::Internet.email,
          challengerColor: 'white'
        )
      end

      it 'raises an exception' do
        move_params = { currentPosition: 'd5', startIndex: 20, pieceType: 'pawn' }
        expect { game.move(move_params) }.to raise_exception(ActiveRecord::RecordInvalid)
      end
    end

    context 'when a pieceType is not valid' do
      let(:game) do
        Game.create(
          challengedEmail: Faker::Name.name,
          challengedName: Faker::Internet.email,
          challengerColor: 'white'
        )
      end
      it 'raises an exception' do
        move_params = { currentPosition: 'd4', startIndex: 20, pieceType: 'queen' }
        expect { game.move(move_params) }.to raise_exception(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe '#current_turn' do
    context 'when the count of moves is even' do
      let(:game) do
        Game.create(
          challengedEmail: Faker::Name.name,
          challengedName: Faker::Internet.email,
          challengerColor: 'white'
        )
      end

      it 'it returns white' do
        expect(game.current_turn).to eq 'white'
      end
    end

    context 'when the count of moves is odd' do
      let(:game) do
        Game.create(
          challengedEmail: Faker::Name.name,
          challengedName: Faker::Internet.email,
          challengerColor: 'white'
        )
      end

      before do
        game.moves.create
      end

      it 'it returns white' do
        expect(game.current_turn).to eq 'black'
      end
    end
  end

  describe '#piece_type_from_notation' do
    context 'when the piece has no capital letters' do
      let(:game) do
        Game.create(
          challengedEmail: Faker::Name.name,
          challengedName: Faker::Internet.email,
          challengerColor: 'white'
        )
      end
      it 'returns pawn' do
        expect(game.piece_type_from_notation('e4')).to eq 'pawn'
      end
    end

    context 'when the piece has an = sign in it' do
      let(:game) do
        Game.create(
          challengedEmail: Faker::Name.name,
          challengedName: Faker::Internet.email,
          challengerColor: 'white'
        )
      end
      it 'returns pawn the piece type that is signified by the last character' do
        expect(game.piece_type_from_notation('e8=Q')).to eq 'queen'
      end
    end

    context 'when the piece has a capital letter and contains no equals sign' do
      let(:game) do
        Game.create(
          challengedEmail: Faker::Name.name,
          challengedName: Faker::Internet.email,
          challengerColor: 'white'
        )
      end

      it 'returns pawn the piece type that is signified by the capital character' do
        expect(game.piece_type_from_notation('Nf7')).to eq 'knight'
      end
    end
  end

  describe '#position_from_notation' do
    context 'when the first character of notation is an O' do
      context 'when the notation is O-O and it is white\'s turn' do
        let(:game) do
          Game.create(
            challengedEmail: Faker::Name.name,
            challengedName: Faker::Internet.email,
            challengerColor: 'white'
          )
        end

        it 'returns g1' do
          expect(game.position_from_notation('O-O')).to eq 'g1'
        end
      end

      context 'when the notation is O-O-O and it is white\'s turn' do
        let(:game) do
          Game.create(
            challengedEmail: Faker::Name.name,
            challengedName: Faker::Internet.email,
            challengerColor: 'white'
          )
        end

        it 'returns c1' do
          expect(game.position_from_notation('O-O-O')).to eq 'c1'
        end
      end

      context 'when the notation is O-O and it is black\'s turn' do
        let(:game) do
          Game.create(
            challengedEmail: Faker::Name.name,
            challengedName: Faker::Internet.email,
            challengerColor: 'white'
          )
        end

        before do
          game.moves.create
        end

        it 'returns g8' do
          expect(game.position_from_notation('O-O')).to eq 'g8'
        end
      end

      context 'when the notation is O-O-O and it is black\'s turn' do
        let(:game) do
          Game.create(
            challengedEmail: Faker::Name.name,
            challengedName: Faker::Internet.email,
            challengerColor: 'white'
          )
        end

        before do
          game.moves.create
        end

        it 'returns c8' do
          expect(game.position_from_notation('O-O-O')).to eq 'c8'
        end
      end
    end
  end

  describe '#retrieve_start_index' do
    xit 'test' do
    end
  end

  describe '#create_move_from_notation' do
    context 'when the notation is e4 on white\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )
      }

      it 'creates a piece on the game with a currentPosition of e4' do

        expect { game.create_move_from_notation('e4', game.pieces) }
          .to change { game.moves.count }.by(1)

        expect(game.moves.last.color).to eq 'white'
        expect(game.moves.last.pieceType).to eq 'pawn'
      end

      it 'updates the piece\'s currentPosition to e4' do
        game.create_move_from_notation('e4', game.pieces)

        expect(game.pieces.detect { |piece| piece.startIndex == 21 }.currentPosition).to eq 'e4'
      end
    end

    context 'when the notation is Bb5 on white\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )
      }

      before do
        white_pawn = game.pieces.find_by(startIndex: 21)
        white_pawn.update(currentPosition: 'e4')
        move_data = white_pawn.attributes
        move_data.delete('id')
        game.moves.create(move_data)

        black_pawn = game.pieces.find_by(startIndex: 13)
        black_pawn.update(currentPosition: 'e5')
        move_data = black_pawn.attributes
        move_data.delete('id')
        game.moves.create(move_data)
      end

      it 'creates a move on the game with a currentPosition of b5' do
        expect { game.create_move_from_notation('Bb5', game.pieces) }
          .to change { game.moves.count }.by(1)

        expect(game.pieces.detect { |piece| piece.startIndex == 30 }
          .currentPosition).to eq 'b5'
        expect(game.moves.last.color).to eq 'white'
        expect(game.moves.last.pieceType).to eq 'bishop'
      end
    end

    context 'when the notation is Nb6 on white\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )
      }

      before do
        piece = game.pieces.find_by(startIndex: 20)
        piece.update(currentPosition: 'd4', hasMoved: true)
        move_data = piece.attributes
        move_data.delete('id')
        game.moves.create(move_data)
      end

      it 'creates a move on the game with a currentPosition of c6' do

        expect { game.create_move_from_notation('Nc6', game.pieces) }
          .to change { game.moves.count }.by(1)

        expect(game.moves.last.currentPosition)
          .to eq 'c6'

        expect(game.moves.last.color)
          .to eq 'black'

        expect(game.moves.last.pieceType)
          .to eq 'knight'
      end
    end

    context 'when the notation is Kd1 on white\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )
      }

      before do
        game.pieces.find_by(currentPosition: 'd1').destroy
      end

      it 'creates a move on the game with a currentPosition of d1' do
        expect { game.reload.create_move_from_notation('Kd1', game.pieces) }
          .to change { game.moves.count }.by(1)

        expect(game.moves.last.currentPosition).to eq 'd1'
        expect(game.moves.last.color).to eq 'white'
        expect(game.moves.last.pieceType).to eq 'king'
      end
    end

    context 'when the notation is Qa1 on white\'s turn' do
      it 'creates a move on the game with a currentPosition of a1' do
        allow_any_instance_of(Game).to receive(:add_pieces)

        game = Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )

        game.pieces.create(
          startIndex: 28,
          currentPosition: 'd1',
          color: 'white',
          pieceType: 'queen'
        )

        game.pieces.create(
          startIndex: 5,
          currentPosition: 'e8',
          color: 'black',
          pieceType: 'king'
        )

        game.pieces.create(
          startIndex: 29,
          currentPosition: 'e1',
          color: 'white',
          pieceType: 'king'
        )

        expect { game.create_move_from_notation('Qa1', game.pieces) }
          .to change { game.moves.count }.by(1)

        expect(game.moves.last.currentPosition).to eq 'a1'
        expect(game.moves.last.color).to eq 'white'
        expect(game.moves.last.pieceType).to eq 'queen'
      end
    end

    context 'when the notation is Rd2 on white\'s turn' do
      it 'creates a move on the game with a currentPosition of d2' do
        allow_any_instance_of(Game).to receive(:add_pieces)

        game = Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )

        game.pieces.create(
          startIndex: 25,
          currentPosition: 'd1',
          color: 'white',
          pieceType: 'rook'
        )

        game.pieces.create(
          startIndex: 5,
          currentPosition: 'e8',
          color: 'black',
          pieceType: 'king'
        )

        game.pieces.create(
          startIndex: 29,
          currentPosition: 'e1',
          color: 'white',
          pieceType: 'king'
        )

        expect { game.create_move_from_notation('Rd2', game.pieces) }
          .to change { game.moves.count }.by(1)

        expect(game.moves.last.currentPosition).to eq 'd2'
        expect(game.moves.last.color).to eq 'white'
        expect(game.moves.last.pieceType).to eq 'rook'
      end
    end

    context 'when the notation is O-O on white\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )
      }

      before do
        game.pieces.where(currentPosition: ['f1', 'g1']).destroy_all
      end

      it 'creates a move on the gam with a currentPosition of g1' do
        expect { game.reload.create_move_from_notation('O-O', game.pieces) }
          .to change { game.moves.count }.by(1)

        expect(game.moves.last.currentPosition).to eq 'g1'
        expect(game.moves.last.color).to eq 'white'
        expect(game.moves.last.pieceType).to eq 'king'
      end
    end

    context 'when the notation is O-O on black\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )
      }

      before do
        piece = game.pieces.find_by(startIndex: 20)
        piece.update(currentPosition: 'd4', hasMoved: true)
        move_data = piece.attributes
        move_data.delete('id')
        game.moves.create(move_data)
        game.pieces.where(currentPosition: ['f8', 'g8']).destroy_all
      end

      it 'creates a move on the game with a currentPosition of g8' do
        expect { game.reload.create_move_from_notation('O-O', game.pieces) }
          .to change { game.moves.count }.by(1)

        expect(game.moves.last.currentPosition).to eq 'g8'
        expect(game.moves.last.color).to eq 'black'
        expect(game.moves.last.pieceType).to eq 'king'
      end
    end

    context 'when the notation is O-O-O on white\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )
      }

      before do
        game.pieces.where(currentPosition: ['d1', 'c1', 'b1']).destroy_all
      end

      it 'creates a piece on the game with a currentPosition of c1' do
        expect { game.reload.create_move_from_notation('O-O-O', game.pieces) }
          .to change { game.moves.count }.by(1)

        expect(game.moves.last.currentPosition).to eq 'c1'
        expect(game.moves.last.color).to eq 'white'
        expect(game.moves.last.pieceType).to eq 'king'
      end
    end

    context 'when the notation is O-O-O on black\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )
      }

      before do
        piece = game.pieces.find_by(startIndex: 20)
        piece.update(currentPosition: 'd4', hasMoved: true)
        move_data = piece.attributes
        move_data.delete('id')
        game.moves.create(move_data)
        game.pieces.where(currentPosition: ['b8', 'c8', 'd8']).destroy_all
      end

      it 'creates a piece on the game with a currentPosition of c8' do
        expect { game.reload.create_move_from_notation('O-O-O', game.pieces) }
          .to change { game.moves.count }.by(1)

        expect(game.moves.last.currentPosition).to eq 'c8'
        expect(game.moves.last.color).to eq 'black'
        expect(game.moves.last.pieceType).to eq 'king'
      end
    end

    context 'when the notation is Nxf6 on black\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )
      }

      before do
        piece = game.pieces.find_by(startIndex: 20)
        piece.update(currentPosition: 'd4', hasMoved: true)
        move_data = piece.attributes
        move_data.delete('id')
        game.moves.create(move_data)
        game.pieces.find_by(currentPosition: 'd1').update(currentPosition: 'f6')
      end

      it 'creates a move on the game with a currentPosition of f6' do
        expect { game.create_move_from_notation('Nxf6', game.pieces) }
          .to change { game.moves.count }.by(1)

        expect(game.moves.last.currentPosition).to eq 'f6'
        expect(game.moves.last.color).to eq 'black'
        expect(game.moves.last.pieceType).to eq 'knight'
      end

      it 'removes a piece from the game' do
        expect(game.create_move_from_notation('Nxf6', game.pieces).length)
          .to eq 31
      end
    end

    context 'when the notation is R6e3 on black\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )
      }

      before do
        piece = game.pieces.find_by(startIndex: 20)
        piece.update(currentPosition: 'd4', hasMoved: true)
        move_data = piece.attributes
        move_data.delete('id')
        game.moves.create(move_data)
        game.pieces.find_by(currentPosition: 'a8').update(currentPosition: 'e6')
      end

      it 'creates a piece on the game with a currentPosition of e3' do
        expect { game.create_move_from_notation('R6e3', game.pieces) }
          .to change { game.moves.count }.by(1)

        expect(game.moves.last.currentPosition).to eq 'e3'
        expect(game.moves.last.color).to eq 'black'
        expect(game.moves.last.pieceType).to eq 'rook'
      end
    end

    context 'when the notation is Rdf8 on black\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )
      }

      before do
        piece = game.pieces.find_by(startIndex: 20)
        piece.update(currentPosition: 'd4', hasMoved: true)
        move_data = piece.attributes
        move_data.delete('id')
        game.moves.create(move_data)
        game.pieces.find_by(startIndex: 5).update(currentPosition: 'd6')
        game.pieces.where(currentPosition: ['e8', 'f8']).destroy_all
        game.pieces.find_by(startIndex: 1).update(currentPosition: 'd8', hasMoved: true)
      end

      it 'creates a move on the game with a currentPosition of f8' do
        expect { game.reload.create_move_from_notation('Rdf8', game.pieces) }
          .to change { game.moves.count }.by(1)
        game.reload
        expect(game.moves.find_by(startIndex: 1).currentPosition).to eq 'f8'
        expect(game.moves.find_by(startIndex: 1).color).to eq 'black'
        expect(game.moves.find_by(startIndex: 1).pieceType).to eq 'rook'
      end
    end

    context 'when the notation is Rd5# on black\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )
      }

      before do
        piece = game.pieces.find_by(startIndex: 20)
        piece.update(currentPosition: 'd4', hasMoved: true)
        move_data = piece.attributes
        move_data.delete('id')
        game.moves.create(move_data)
        game.pieces.find_by(startIndex: 8).update(currentPosition: 'a5', hasMoved: true)
      end

      it 'creates a move on the game with a currentPosition of d5' do
        expect { game.create_move_from_notation('Rd5#', game.pieces) }
          .to change { game.moves.count }.by(1)

        expect(game.moves.last.currentPosition).to eq 'd5'
        expect(game.moves.last.color).to eq 'black'
        expect(game.moves.last.pieceType).to eq 'rook'
      end
    end

    context 'when the notation is d5# on black\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )
      }

      before do
        piece = game.pieces.find_by(startIndex: 20)
        piece.update(currentPosition: 'd4', hasMoved: true)
        move_data = piece.attributes
        move_data.delete('id')
        game.moves.create(move_data)
      end

      it 'creates a move on the game with a currentPosition of d5' do
        expect { game.create_move_from_notation('d5#', game.pieces) }
          .to change { game.moves.count }.by(1)

        expect(game.moves.last.currentPosition).to eq 'd5'
        expect(game.moves.last.color).to eq 'black'
        expect(game.moves.last.pieceType).to eq 'pawn'
      end
    end

    context 'when the notation is f1=Q. on black\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          human: false,
          challengerColor: 'black'
        )
      }

      before do
        piece = game.pieces.find_by(startIndex: 20)
        piece.update(currentPosition: 'd4', hasMoved: true)
        move_data = piece.attributes
        move_data.delete('id')
        game.moves.create(move_data)
        game.pieces.where(currentPosition: ['f1', 'f2']).destroy_all
        game.pieces.find_by(startIndex: 13).update(currentPosition: 'f2', hasMoved: true)
      end

      it 'creates a move on the game with a currentPosition of f1' do
        expect { game.reload.create_move_from_notation('f1=Q', game.pieces) }
          .to change { game.moves.count }.by(1)

        expect(game.moves.last.currentPosition).to eq 'f1'
        expect(game.moves.last.color).to eq 'black'
        expect(game.moves.last.pieceType).to eq 'queen'
        expect(game.moves.last.startIndex).to eq 13
      end

      it 'updates the pawn on f1 to a queen' do
        game.reload.create_move_from_notation('f1=Q', game.pieces)
        expect(game.pieces.detect { |piece| piece.startIndex == 13 }.pieceType)
          .to eq 'queen'
      end
    end
  end

  describe '#add_pieces' do
    it 'creates 32 pieces for a given game' do
      game = Game.create(
        pending: false,
        challengedName: Faker::Name.name,
        challengedEmail: Faker::Internet.email,
        human: false,
        challengerColor: 'black'
      )

      expect(game.pieces.count).to eq 32
    end
  end

  describe '#find_start_position' do
    xit 'test' do
    end
  end

  describe '#handle_en_passant' do
    context 'when the piece type is a pawn '
    it 'test' do
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

  describe '#previously_moved_piece' do
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
    let(:game) {
      Game.create(
        pending: false,
        challengedName: Faker::Name.name,
        challengedEmail: Faker::Internet.email,
        human: false,
        challengerColor: 'black'
      )
    }

    context 'when the pieceType is equal to the pieceType of the current piece' do
      it 'returns true' do
        expect(game.valid_piece_type?({ startIndex: 5, pieceType: 'king' })).to be true
      end
    end

    context 'when crossed_pawn? is true' do
      it 'returns true' do
        allow_any_instance_of(Game).to receive(:crossed_pawn?)
          .with({ startIndex: 11, pieceType: 'queen' }).and_return true

        expect(game.valid_piece_type?({ startIndex: 11, pieceType: 'queen' })).to be true
      end
    end

    context 'when crossed_pawn? is false and the pieceTypes do not match' do
      it 'returns false' do
        expect(game.valid_piece_type?({
          startIndex: 11,
          pieceType: 'queen',
          currentPosition: 'e5'
        })).to be false
      end
    end
  end

  describe '#value_from_column' do
    xit 'test' do
    end
  end

  describe '#value_from_moves' do
    xit 'test' do
    end
  end
end
