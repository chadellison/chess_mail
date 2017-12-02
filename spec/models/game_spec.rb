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
        expect(game.outcome).to eq -1
      end
    end

    context 'when the current player is black' do
      it 'updates the game so that white wins' do
        game.handle_resign(challenged_user)
        expect(game.outcome).to eq 1
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

    context 'when robot is not present' do
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
          challengerColor: 'white'
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
        allow_any_instance_of(Game).to receive(:stalemate?).and_return(false)
        allow_any_instance_of(Game).to receive(:checkmate?).and_return(false)

        move_params = { currentPosition: 'a7', startIndex: 5, pieceType: 'king' }
        expect_any_instance_of(Game).to receive(:move).with(move_params)
        expect_any_instance_of(Game).to receive(:send_new_move_email)
        game.handle_move(move_params, user)
      end
    end

    context 'when robot is present' do
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
          robot: true
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

      it 'calls ai_move' do
        allow_any_instance_of(Game).to receive(:stalemate?).and_return(false)
        allow_any_instance_of(Game).to receive(:checkmate?).and_return(false)

        move_params = { currentPosition: 'a7', startIndex: 5, pieceType: 'king' }
        allow_any_instance_of(Game).to receive(:move).with(move_params)
        expect_any_instance_of(Game).to receive(:ai_move)

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
          challengerColor: 'white',
          move_signature: 'd4.'
        )
      end

      before do
        game.moves.create
      end

      it 'it returns black' do
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
            challengerColor: 'white',
            move_signature: 'd4.'
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
            challengerColor: 'white',
            move_signature: 'd4.'
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
    let(:game) {
      Game.create(
        pending: false,
        challengedName: Faker::Name.name,
        challengedEmail: Faker::Internet.email,
        robot: true,
        challengerColor: 'black'
      )
    }

    context 'when the piece type is a king' do
      it 'returns the startIndex of the king' do
        expect(game.retrieve_start_index('Ke2', game.pieces)).to eq 29
      end
    end

    context 'when the notation has a start position with a row and column' do
      it 'returns the startIndex of the piece on that square' do
        expect(game.retrieve_start_index('b7b5', game.pieces)).to eq 10
      end
    end

    context 'when the start position is only one character' do
      it 'calls value_from_column' do
        expect_any_instance_of(Game).to receive(:value_from_column)
          .with('Rad4', 'rook', 'a', game.pieces)

        game.retrieve_start_index('Rad4', game.pieces)
      end
    end

    context 'when the start position is empty' do
      it 'calls value_from_column' do
        expect_any_instance_of(Game).to receive(:value_from_moves)
          .with('Bd4', 'bishop', game.pieces)

        game.retrieve_start_index('Bd4', game.pieces)
      end
    end
  end

  describe '#create_move_from_notation' do
    context 'when the notation is e4 on white\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
          challengerColor: 'black'
        )
      }

      it 'creates a piece on the game with a currentPosition of e4' do

        actual = game.create_move_from_notation('e4', game.pieces)
        expected = {
          pieceType: 'pawn',
          currentPosition: 'e4',
          startIndex: 21,
          notation: 'e4.'
        }
        expect(actual).to eq expected
      end
    end

    context 'when the notation is Bb5 on white\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
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
        actual = game.create_move_from_notation('Bb5', game.pieces)
        expected = {
          pieceType: 'bishop',
          currentPosition: 'b5',
          startIndex: 30,
          notation: 'Bb5.'
        }
        expect(actual).to eq expected
      end
    end

    context 'when the notation is Nb6 on white\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
          challengerColor: 'black',
          move_signature: 'd4.'
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
        actual = game.create_move_from_notation('Nc6', game.pieces)

        expected = {
          pieceType: 'knight',
          currentPosition: 'c6',
          startIndex: 2,
          notation: 'Nc6.'
        }
        expect(actual).to eq expected
      end
    end

    context 'when the notation is Kd1 on white\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
          challengerColor: 'black'
        )
      }

      before do
        game.pieces.find_by(currentPosition: 'd1').destroy
      end

      it 'returns move data with a currentPosition of d1' do
        actual = game.create_move_from_notation('Kd1', game.pieces)
        expected = {
          currentPosition: 'd1',
          startIndex: 29,
          pieceType: 'king',
          notation: 'Kd1.'
        }

        expect(actual).to eq expected
      end
    end

    context 'when the notation is Qa1 on white\'s turn' do
      it 'creates a move on the game with a currentPosition of a1' do
        allow_any_instance_of(Game).to receive(:add_pieces)

        game = Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
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

        actual = game.create_move_from_notation('Qa1', game.pieces)
        expected = {
          startIndex: 28,
          currentPosition: 'a1',
          pieceType: 'queen',
          notation: 'Qa1.'
        }
        expect(actual).to eq expected
      end
    end

    context 'when the notation is Rd2 on white\'s turn' do
      it 'creates a move on the game with a currentPosition of d2' do
        allow_any_instance_of(Game).to receive(:add_pieces)

        game = Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
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

        actual = game.create_move_from_notation('Rd2', game.pieces)
        expected = {
          currentPosition: 'd2',
          pieceType: 'rook',
          startIndex: 25,
          notation: 'Rd2.'
        }
        expect(actual).to eq expected
      end
    end

    context 'when the notation is O-O on white\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
          challengerColor: 'black'
        )
      }

      before do
        game.pieces.where(currentPosition: ['f1', 'g1']).destroy_all
      end

      it 'creates a move on the gam with a currentPosition of g1' do
        actual = game.reload.create_move_from_notation('O-O', game.pieces)
        expected = {
          startIndex: 29,
          currentPosition: 'g1',
          pieceType: 'king',
          notation: 'O-O.'
        }
        expect(actual).to eq expected
      end
    end

    context 'when the notation is O-O on black\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
          challengerColor: 'black',
          move_signature: 'd4.'
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
        actual = game.reload.create_move_from_notation('O-O', game.pieces)
        expected = {
          currentPosition: 'g8',
          startIndex: 5,
          pieceType: 'king',
          notation: 'O-O.'
        }
        expect(actual).to eq expected
      end
    end

    context 'when the notation is O-O-O on white\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
          challengerColor: 'black'
        )
      }

      before do
        game.pieces.where(currentPosition: ['d1', 'c1', 'b1']).destroy_all
      end

      it 'creates a piece on the game with a currentPosition of c1' do
        actual = game.reload.create_move_from_notation('O-O-O', game.pieces)
        expected = {
          pieceType: 'king',
          currentPosition: 'c1',
          startIndex: 29,
          notation: 'O-O-O.'
        }

        expect(actual).to eq expected
      end
    end

    context 'when the notation is O-O-O on black\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
          challengerColor: 'black',
          move_signature: 'd4.'
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
        actual = game.reload.create_move_from_notation('O-O-O', game.pieces)
        expected = {
          startIndex: 5,
          pieceType: 'king',
          currentPosition: 'c8',
          notation: 'O-O-O.'
        }

        expect(actual).to eq expected
      end
    end

    context 'when the notation is Nxf6 on black\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
          challengerColor: 'black',
          move_signature: 'd4.'
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
        actual = game.create_move_from_notation('Nxf6', game.pieces)
        expected = {
          startIndex: 7,
          pieceType: 'knight',
          currentPosition: 'f6',
          notation: 'Nxf6.'
        }
        expect(actual).to eq expected
      end
    end

    context 'when the notation is R6e3 on black\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
          challengerColor: 'black',
          move_signature: 'd4.'
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
        actual = game.create_move_from_notation('R6e3', game.pieces)
          expected = {
            startIndex: 1,
            pieceType: 'rook',
            currentPosition: 'e3',
            notation: 'R6e3.'
          }
        expect(actual).to eq expected
      end
    end

    context 'when the notation is Rdf8 on black\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
          challengerColor: 'black',
          move_signature: 'd4.'
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
        actual = game.reload.create_move_from_notation('Rdf8', game.pieces)

        expected = {
          startIndex: 1,
          pieceType: 'rook',
          currentPosition: 'f8',
          notation: 'Rdf8.'
        }

        expect(actual).to eq expected
      end
    end

    context 'when the notation is Rd5# on black\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
          challengerColor: 'black',
          move_signature: 'd4.'
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
        actual = game.create_move_from_notation('Rd5#', game.pieces)
        expected = {
          startIndex: 8,
          pieceType: 'rook',
          currentPosition: 'd5',
          notation: 'Rd5.'
        }
        expect(actual).to eq expected
      end
    end

    context 'when the notation is d5# on black\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
          challengerColor: 'black',
          move_signature: 'd4.'
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
        actual = game.create_move_from_notation('d5#', game.pieces)
        expected = {
          startIndex: 12,
          pieceType: 'pawn',
          currentPosition: 'd5',
          notation: 'd5.'
        }
        expect(actual).to eq expected
      end
    end

    context 'when the notation is f1=Q. on black\'s turn' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
          challengerColor: 'black',
          move_signature: 'd4.'
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
        actual = game.reload.create_move_from_notation('f1=Q', game.pieces)
        expected = {
          startIndex: 13,
          pieceType: 'queen',
          currentPosition: 'f1',
          notation: 'f1=Q.'
        }
        expect(actual).to eq expected
      end

      it 'updates the pawn on f1 to a queen' do
        actual = game.create_move_from_notation('f1=Q', game.pieces)
        expected = {
          pieceType: 'queen',
          currentPosition: 'f1',
          startIndex: 13,
          notation: 'f1=Q.'
        }
        expect(actual).to eq expected
      end
    end
  end

  describe '#add_pieces' do
    it 'creates 32 pieces for a given game' do
      game = Game.create(
        pending: false,
        challengedName: Faker::Name.name,
        challengedEmail: Faker::Internet.email,
        robot: true,
        challengerColor: 'black'
      )

      expect(game.pieces.count).to eq 32
    end
  end

  describe '#find_start_position' do
    context 'when the notation does not include a start position' do
      it 'returns an empty string' do
        game = Game.new

        expect(game.find_start_position('d4')).to eq ''
      end
    end

    context 'when the notation includes a column' do
      it 'returns the letter of that column' do
        game = Game.new

        expect(game.find_start_position('exd4')).to eq 'e'
      end
    end

    context 'when the notation includes a row and a column' do
      it 'returns both coordinates' do
        game = Game.new

        expect(game.find_start_position('Ra2a4')).to eq 'a2'
      end
    end
  end

  describe '#handle_en_passant' do
    context 'when the piece type is a pawn ' do
      it 'test' do
      end
    end
  end

  describe '#en_passant?' do
    context 'when a pawn can en Passant' do
      let!(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
          challengerColor: 'black'
        )
      }

      before do
        game.pieces.find_by(startIndex: 20).update(currentPosition: 'd4')
        game.pieces.find_by(startIndex: 13).update(currentPosition: 'e4', movedTwo: true)
      end

      it 'returns true' do
        piece = game.pieces.find_by(startIndex: 20)

        expect(game.en_passant?('e5', piece)).to be true
      end
    end

    context 'when a pawn cannot en Passant' do
      let!(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
          challengerColor: 'black'
        )
      }

      it 'returns false' do
        piece = game.pieces.find_by(startIndex: 20)

        expect(game.en_passant?('c7', piece)).to be false
      end
    end
  end

  describe '#handle_castle' do
    context 'when the king has castled queen side' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
          challengerColor: 'black'
        )
      }

      it 'updates the rook\'s currentPosition to the f column' do
        piece = game.pieces.find_by(startIndex: 29)

        game.handle_castle({ currentPosition: 'c1' }, piece)

        expect(game.pieces.find_by(startIndex: 25).currentPosition).to eq 'd1'
      end
    end

    context 'when the king has castled king side' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
          challengerColor: 'black'
        )
      }

      it 'updates the rook\'s currentPosition to the f column' do
        piece = game.pieces.find_by(startIndex: 29)

        game.handle_castle({ currentPosition: 'g1' }, piece)

        expect(game.pieces.find_by(startIndex: 32).currentPosition).to eq 'f1'
      end
    end

    context 'when the king has not moved two spaces' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
          challengerColor: 'black'
        )
      }

      it 'does nothing' do
        piece = game.pieces.find_by(startIndex: 29)

        game.handle_castle({ currentPosition: 'f1' }, piece)

        expect(game.pieces.find_by(startIndex: 25).currentPosition).to eq 'a1'
        expect(game.pieces.find_by(startIndex: 32).currentPosition).to eq 'h1'
      end
    end
  end

  describe '#handle_captured_piece' do
    context 'when there is a piece on the square' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
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
    # def crossed_pawn?(move_params)
    #   piece = pieces.find_by(startIndex: move_params[:startIndex])
    #
    #   piece.pieceType == 'pawn' &&
    #     piece.color == 'white' && move_params[:currentPosition][1] == '8' ||
    #     piece.color == 'black' && move_params[:currentPosition][1] == '1'
    # end
    context 'when the pawn is on row 8' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
          challengerColor: 'black'
        )
      }

      it 'returns true' do
        expect(game.crossed_pawn?({ startIndex: 17, currentPosition: 'a8' })).to be true
      end
    end

    context 'when the pawn is on row 1' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
          challengerColor: 'black'
        )
      }
      it 'returns true' do
        expect(game.crossed_pawn?({ startIndex: 9, currentPosition: 'a1' })).to be true
      end
    end

    context 'when the pawn is not on row 1 or 8' do
      let(:game) {
        Game.create(
          pending: false,
          challengedName: Faker::Name.name,
          challengedEmail: Faker::Internet.email,
          robot: true,
          challengerColor: 'black'
        )
      }
      it 'returns false' do
        expect(game.crossed_pawn?({ startIndex: 9, currentPosition: 'a6' })).to be false
      end
    end
  end

  describe '#valid_piece_type?' do
    let(:game) {
      Game.create(
        pending: false,
        challengedName: Faker::Name.name,
        challengedEmail: Faker::Internet.email,
        robot: true,
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

  describe '#checkmate?' do
    let(:game) {
      Game.create(
        challengedEmail: Faker::Internet.email,
        challengedName: Faker::Name.name,
        challengerColor: 'white'
      )
    }

    context 'when the king is in checkmate' do
      before do
        game.pieces.find_by(currentPosition: 'e2').update(currentPosition: 'd4')
        game.pieces.find_by(currentPosition: 'e7').update(currentPosition: 'd5')
        game.pieces.find_by(currentPosition: 'd1').update(currentPosition: 'f7')
        game.pieces.find_by(currentPosition: 'b8').update(currentPosition: 'c6')
        game.pieces.find_by(currentPosition: 'f1').update(currentPosition: 'c4')
        game.pieces.find_by(currentPosition: 'g8').update(currentPosition: 'f6')
      end

      it 'returns true' do
        allow_any_instance_of(Game).to receive(:current_turn)
          .and_return('black')
        expect(game.checkmate?).to be true
      end
    end

    context 'when the king is not in checkmate' do
      it 'returns false' do
        expect(game.checkmate?).to be false
      end
    end
  end

  describe '#stalemate?' do
    xit 'test' do
    end
  end

  describe '#create_notation' do
    let(:game) {
      Game.create(
        challengedEmail: Faker::Internet.email,
        challengedName: Faker::Name.name,
        challengerColor: 'white',
        move_signature: 'a4.'
      )
    }

    context 'for a pawn move' do
      xit 'test' do
      end
    end

    context 'when a pawn kills another piece' do
      xit 'test' do
      end
    end

    context 'for a castle king side' do
      xit 'test' do
      end
    end

    context 'for a castle queen side' do
      xit 'test' do
      end
    end

    context 'for a knight' do
      xit 'test' do
      end
    end

    context 'for a knight when both knights can move on a given position' do
      xit 'test' do
      end
    end

    context 'for a rook when two rooks are on the same column' do
      xit 'test' do
      end
    end

    context 'for a rook when two rooks are on the same row' do
      xit 'test' do
      end
    end

    context 'for a crossed pawn' do
      xit 'test' do
      end
    end
  end

  describe '#same_piece_types' do
    xit 'test' do
    end
  end

  describe '#start_notation' do
    xit 'test' do
    end
  end

  describe '#similar_pieces' do
    xit 'test' do
    end
  end

  describe '#capture_notation' do
    xit 'test' do
    end
  end

  describe '#upgraded_pawn?' do
    xit 'test' do
    end
  end

  describe '#update_board' do
    let(:game) {
      Game.create(
        challengedEmail: Faker::Internet.email,
        challengedName: Faker::Name.name,
        challengerColor: 'white',
        move_signature: '.a4'
      )
    }

    it 'calls handle_captured_piece' do
      move_params = { startIndex: 4, currentPosition: 'd5', pieceType: 'queen' }
      piece = game.pieces.find_by(startIndex: 4)

      expect_any_instance_of(Game).to receive(:handle_captured_piece)
        .with(move_params, piece)

      game.update_board(move_params, piece)
      expect(game.pieces.find_by(startIndex: 4).currentPosition).to eq 'd5'
    end
  end

  describe '#ai_move' do
    context 'when best move signature is present' do
      let(:old_game) {
        Game.create(
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white',
          outcome: 1,
          move_signature: 'd4.',
          robot: true
        )
      }

      let(:game) {
        Game.create(
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white',
          robot: true
        )
      }

      let(:piece_data) {
        {
          startIndex: 20,
          currentPosition: 'd4',
          pieceType: 'pawn',
          notation: 'd4.'
        }
      }

      before do
        old_game.moves.create(piece_data)
      end

      it 'calls move on a game with the last game\'s move data' do
        expect_any_instance_of(Game).to receive(:move).with(piece_data)
        game.ai_move
      end

      it 'does not call non loss move on a game with the last game\'s move data' do
        expect_any_instance_of(Game).not_to receive(:non_loss_move)
        game.ai_move
      end

      it 'calls move on a game with the last game\'s move data' do
        expect_any_instance_of(Game).not_to receive(:random_move)
        game.ai_move
      end
    end

    context 'when the best move signature is not present' do
      let(:old_game) {
        Game.create(
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white',
          move_signature: ' 20:d4',
          robot: true,
          outcome: 0
        )
      }

      let(:game) {
        Game.create(
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white',
          robot: true
        )
      }

      let(:piece_data) {
        {
          startIndex: 26,
          currentPosition: 'c3',
          pieceType: 'knight'
        }
      }

      before do
        old_game.moves.create(piece_data)
      end

      it 'calls non_loss_move' do
        expect_any_instance_of(Game).to receive(:non_loss_move)
        game.ai_move
      end

      it 'calls does not call random_move' do
        expect_any_instance_of(Game).not_to receive(:random_move)
        game.ai_move
      end

      it 'calls move' do
        expect_any_instance_of(Game).to receive(:move)
        game.ai_move
      end
    end

    context 'when the best move signature and non_loss_move are not present' do
      let(:game) {
        Game.create(
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white',
          robot: true
        )
      }

      it 'calls move' do
        allow_any_instance_of(Game).to receive(:non_loss_move).and_return(nil)

        expect_any_instance_of(Game).to receive(:move)
        game.ai_move
      end
    end
  end

  describe '#random_move' do
    it 'returns a hash of move data that is a valid move given the current game' do
      game = Game.create(
        challengedEmail: Faker::Internet.email,
        challengedName: Faker::Name.name,
        challengerColor: 'white',
        robot: true,
        move_signature: ' 20:d4'
      )

      move = game.random_move
      piece = game.pieces.find_by(startIndex: move[:startIndex])

      expect(piece.valid_move?(move[:currentPosition])).to be true
    end
  end

  describe '#piece_with_valid_moves' do
    context 'when the count is greater than 10 and the piece has no valid moves' do
      it 'returns nil' do
        game = Game.create(
          challengedEmail: Faker::Internet.email,
          challengedName: Faker::Name.name,
          challengerColor: 'white',
          robot: true
        )
        allow_any_instance_of(Piece).to receive(:valid_moves).and_return([])
        expect(game.piece_with_valid_moves([], 11)).to be_nil
      end
    end
  end

  describe '#winning_games' do
    let!(:win) {
      Game.new(
        outcome: 1,
        robot: true
      )
    }

    let!(:draw) {
      Game.create(
        challengedEmail: Faker::Internet.email,
        challengedName: Faker::Name.name,
        challengerColor: 'white',
        outcome: 0
      )
    }

    it 'returns winning games of the given color' do
      win.save(validate: false)
      expect(Game.winning_games(1, 'white').last).to eq win
      expect(Game.winning_games(1, 'white').count).to eq 1
    end
  end

  describe '#drawn_games' do
    let!(:wins) {
      Game.create(
        challengedEmail: Faker::Internet.email,
        challengedName: Faker::Name.name,
        challengerColor: 'white',
        outcome: 1
      )
    }

    let!(:draw) {
      Game.create(
        challengedEmail: Faker::Internet.email,
        challengedName: Faker::Name.name,
        challengerColor: 'white',
        outcome: 0
      )
    }

    it 'returns games with the outcome of draw' do
      expect(Game.drawn_games.last).to eq draw
      expect(Game.drawn_games.count).to eq 1
    end
  end

  describe '#similar_games' do
    let(:move_signature) { ' 9:a6 18:b4' }

    before do
      3.times do |n|
        game = Game.new
        game.save(validate: false)
        game.update_attribute(:robot, true)
        game.update_attribute(:move_signature, move_signature) if n.even?
      end
    end

    context 'when the move signature matches previous games' do
      it 'returns games that match that game\'s move signature' do
        expect(Game.similar_games(move_signature).count).to eq 2
        expect(Game.similar_games(move_signature).map(&:move_signature))
          .to eq [move_signature, move_signature]
      end
    end

    context 'when the move signature matches previous games\' beginnings' do
      it 'returns games that match that game\'s move signature' do
        expect(Game.similar_games(' 9:a6').count).to eq 2
        expect(Game.similar_games(move_signature).map(&:move_signature))
          .to eq [move_signature, move_signature]
      end
    end
  end

  describe '#find_outcome' do
    xit 'returns a move that matches that game\'s next move' do
    end
  end

  describe '#non_loss_move' do
    context 'when piece_with_valid_moves is not present' do
      it 'returns nil' do
        game = Game.create(
          challengedName: Faker::Name.first_name,
          challengedEmail: Faker::Internet.email,
          challengerColor: 'white'
        )

        allow_any_instance_of(Game).to receive(:piece_with_valid_moves)
          .and_return(nil)

        expect(game.non_loss_move).to be_nil
      end
    end

    context 'when piece_with_valid_moves is present' do
      it 'returns a move with the correct move properties' do
        game = Game.create(
          challengedName: Faker::Name.first_name,
          challengedEmail: Faker::Internet.email,
          challengerColor: 'white'
        )

        piece = game.pieces.find_by(startIndex: 20)
        piece_with_moves_hash = { piece => ['d4'] }

        allow_any_instance_of(Game).to receive(:piece_with_valid_moves)
          .and_return(piece_with_moves_hash)

        result = game.non_loss_move

        expect(result[:currentPosition]).to eq 'd4'
        expect(result[:startIndex]).to eq 20
        expect(result[:pieceType]).to eq 'pawn'
      end
    end
  end

  describe '#find_bad_moves' do
    it 'returns an array of each move signature that lead to a lost game' do
      old_game = Game.create(
        challengedName: Faker::Name.first_name,
        challengedEmail: Faker::Internet.email,
        challengerColor: 'white',
        robot: true,
        outcome: -1,
        move_signature: 'd4.'
      )

      old_game.moves.create(startIndex: 20, pieceType: 'pawn', currentPosition: 'd4')

      game = Game.create(
        challengedName: Faker::Name.first_name,
        challengedEmail: Faker::Internet.email,
        challengerColor: 'white'
      )
      expect(game.find_bad_moves).to eq ['d4']
    end
  end

  describe '#oppoenent_color' do
    context 'when it is white\'s turn' do
      it 'returns black' do
        game = Game.create(
          challengedName: Faker::Name.first_name,
          challengedEmail: Faker::Internet.email,
          challengerColor: 'white'
        )
        expect(game.opponent_color).to eq 'black'
      end
    end

    context 'when it is black\'s turn' do
      it 'returns white' do
        game = Game.create(
          challengedName: Faker::Name.first_name,
          challengedEmail: Faker::Internet.email,
          challengerColor: 'white',
          move_signature: 'd4.'
        )
        game.moves.create

        expect(game.opponent_color).to eq 'white'
      end
    end
  end

  describe '#filter_bad_moves' do
    it 'filters out all moves that are included in the bad moves array' do
      piece = Piece.new(startIndex: 20)
      game = Game.new
      allow_any_instance_of(Piece).to receive(:valid_moves)
        .and_return(['20:d4', '20:d3'])

      expect(game.filter_bad_moves(piece, ['20:d3'])).to eq ['20:d4']
    end
  end

  describe '#similar_patterned_game' do
    xit 'test' do
    end
  end

  describe '#handle_archive' do
    xit 'test' do
    end
  end

  describe '#update_crossed_pawn' do
  end
end
