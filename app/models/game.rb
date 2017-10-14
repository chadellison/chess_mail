class Game < ApplicationRecord
  has_many :user_games
  has_many :users, through: :user_games
  has_many :pieces
  has_many :moves

  validates_presence_of :challengedName, :challengedEmail, :challengerColor

  after_commit :add_pieces, on: :create

  scope :not_archived, ->(archived_game_ids) { where.not(id: archived_game_ids) }
  scope :similar_game, ->(move_signature) { where('move_signature LIKE ?', "#{move_signature}%") }
  scope :winning_game, ->(color) { where(outcome: color + 'wins') }
  scope :drawn_game, -> { where(outcome: 'draw') }

  include NotationLogic

  class << self
    def serialize_games(games, user_email)
      {
        data: games.map { |game| game.serialize_game(user_email) },
        meta: { count: games.count }
      }
    end
  end

  def ai_move
    # if not checkmate or draw
    game = Game.similar_game(move_signature)
    game = game.drawn_game if game.drawn_game.present?
    game = game.winning_game(current_turn) if game.winning_game(current_turn).present?

    next_move = game.all.sample.moves[moves.count] if game.present?
    next_move = random_move unless next_move.present?

    move(
      currentPosition: next_move.currentPosition,
      startIndex: next_move.startIndex,
      pieceType: next_move.pieceType
    )
  end

  def random_move
    ai_piece = pieces.reload.where(color: current_turn).all.reject do |game_piece|
      game_piece.valid_moves.empty?
    end.sample

    Move.new(
      currentPosition: ai_piece.valid_moves.sample,
      startIndex: ai_piece.startIndex,
      pieceType: ai_piece.pieceType
    )
  end

  def serialize_game(user_email)
    opponent_email = current_opponent_email(user_email).downcase.strip
    opponent_gravatar = Digest::MD5.hexdigest(opponent_email)

    {
      type: 'game',
      id: id,
      attributes: {
        pending: pending,
        playerColor: current_player_color(user_email),
        opponentName: current_opponent_name(user_email),
        opponentGravatar: opponent_gravatar,
        isChallenger: challenger?(user_email),
        outcome: outcome,
        human: human
      },
      included: moves.order(:updated_at).map(&:serialize_move)
    }
  end

  def challenger?(email)
    challengedEmail != email
  end

  def current_player_color(email)
    if challengedEmail == email
      challengerColor == 'white' ? 'black' : 'white'
    else
      challengerColor
    end
  end

  def current_opponent_name(email)
    if challengedEmail == email
      users.where.not(email: email).first.firstName
    else
      challengedName
    end
  end

  def current_opponent_email(email)
    if challengedEmail == email
      users.where.not(email: email).first.email
    else
      challengedEmail
    end
  end

  def setup(user)
    if human == true
      add_challenged_player
      send_challenge_email(user)
    else
      update(
        pending: false,
        challengedEmail: Faker::Internet.email,
        challengedName: Faker::Name.first_name
      )
      pieces.create(
        pieceType: 'pawn',
        color: 'white',
        currentPosition: 'd4',
        hasMoved: true,
        movedTwo: true,
        startIndex: 20
      ) if pieces.empty? && challengerColor == 'black'
    end
  end

  def handle_move(move_params, user)
    move(move_params)

    if human.present?
      send_new_move_email(move_params[:currentPosition], move_params[:pieceType], user)
    else
      ai_move
    end
  end

  def move(move_params)
    piece = pieces.find_by(startIndex: move_params[:startIndex])

    if piece.valid_moves.include?(move_params[:currentPosition]) && valid_piece_type?(move_params)
      move_params[:hasMoved] = true
      update_board(move_params, piece)
      create_move(piece)
      update_move_signature(move_params)
      piece
    else
      raise ActiveRecord::RecordInvalid
    end
  end

  def create_move(piece)
    move = piece.attributes
    move.delete('id')
    moves.create(move)
  end

  def update_board(move_params, piece)
    piece.handle_moved_two(move_params[:currentPosition]) if piece.pieceType == 'pawn'
    handle_castle(move_params, piece) if piece.pieceType == 'king'
    handle_captured_piece(move_params, piece)
    piece.update(move_params)
  end

  def update_move_signature(move_params)
    updated_signature = "#{move_signature} #{move_params[:startIndex]}" \
                          ":#{move_params[:currentPosition]}"

    update_attribute(:move_signature, updated_signature)
  end

  def crossed_pawn?(move_params)
    color = pieces.find_by(startIndex: move_params[:startIndex]).color

    pieces.find_by(startIndex: move_params[:startIndex]).pieceType == 'pawn' &&
      color == 'white' && move_params[:currentPosition][1] == '8' ||
      color == 'black' && move_params[:currentPosition][1] == '1'
  end

  def checkmate?
    pieces.where(color: current_turn).all? do |piece|
      piece.valid_moves.blank?
    end &&
      !pieces.find_by(color: current_turn).king_is_safe?(current_turn, pieces)
  end

  def valid_piece_type?(move_params)
    move_params[:pieceType] == pieces.find_by(startIndex: move_params[:startIndex]).pieceType ||
      crossed_pawn?(move_params)
  end

  def handle_castle(move_params, piece)
    column_difference = piece.currentPosition[0].ord - move_params[:currentPosition][0].ord
    row = piece.color == 'white' ? '1' : '8'

    if column_difference == -2
      pieces.find_by(currentPosition: ('h' + row)).update(currentPosition: ('f' + row))
    end

    if column_difference == 2
      pieces.find_by(currentPosition: ('a' + row)).update(currentPosition: ('d' + row))
    end
  end

  def handle_captured_piece(move_params, piece)
    captured_piece = pieces.find_by(currentPosition: move_params[:currentPosition])
    if en_passant?(move_params[:currentPosition], piece)
      captured_piece = handle_en_passant(move_params, piece)
    end

    captured_piece.destroy if captured_piece.present?
  end

  def handle_en_passant(move_params, piece)
    captured_position = move_params[:currentPosition][0] + piece.currentPosition[1]
    captured_piece = pieces.find_by(currentPosition: captured_position)
  end

  def en_passant?(position, piece)
    [
      piece.pieceType == 'pawn',
      piece.currentPosition[0] != position[0],
      pieces.find_by(currentPosition: position).blank?
    ].all?
  end

  def add_challenged_player
    user = User.find_by(email: challengedEmail)
    users << user if user
  end

  def handle_resign(user)
    if current_player_color(user.email) == 'white'
      update(outcome: 'black wins!')
    else
      update(outcome: 'white wins!')
    end
  end

  def send_challenge_email(user)
    challenged_player = User.find_by(email: challengedEmail)
    token = challenged_player ? challenged_player.token : ''

    ChallengeMailer.challenge(
      "#{user.firstName.capitalize} #{user.lastName.capitalize}",
      challengedName,
      challengedEmail,
      "#{ENV['api_host']}/api/v1/accept_challenge/#{id}?token=#{token}&from_email=true"
    ).deliver_later
  end

  def send_new_move_email(piece_position, piece_type, user)
    recipient = users.detect { |each_user| each_user != user }
    opponent_name = user.firstName
    MoveMailer.move(recipient, opponent_name, piece_position, piece_type)
              .deliver_later
  end

  def add_pieces
    json_pieces = JSON.parse(File.read(Rails.root + 'json/pieces.json'))

    json_pieces.deep_symbolize_keys.values.each do |json_piece|
      pieces.create(json_piece[:piece])
    end
  end
end
