class Game < ApplicationRecord
  has_many :user_games
  has_many :users, through: :user_games
  has_many :pieces
  has_many :moves

  validates_presence_of :challengedName, :challengedEmail, :challengerColor

  after_commit :add_pieces, on: :create

  scope :not_archived, ->(archived_game_ids) { where.not(id: archived_game_ids) }

  include NotationLogic

  class << self
    def serialize_games(games, user_email)
      {
        data: games.map { |game| game.serialize_game(user_email) },
        meta: { count: games.count }
      }
    end
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
    user_piece = move(move_params)

    if human.present?
      send_new_move_email(user_piece, user)
    else
      turn = moves.count.even? ? 'white' : 'black'
      ai_piece = pieces.where(color: turn).all.reject do |game_piece|
        game_piece.valid_moves.empty?
      end.sample

      move(currentPosition: ai_piece.valid_moves.sample,
           startIndex: ai_piece.startIndex,
           pieceType: ai_piece.pieceType)
    end
  end

  def move(move_params)
    piece = pieces.find_by(startIndex: move_params[:startIndex])

    if piece.valid_moves.include?(move_params[:currentPosition]) && valid_piece_type?(move_params)
      move_params[:hasMoved] = true
      piece.handle_moved_two(move_params[:currentPosition]) if piece.pieceType == 'pawn'
      handle_castle(move_params, piece) if piece.pieceType == 'king'
      handle_captured_piece(move_params, piece)
      piece.update(move_params)
      create_move(piece)
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

  def crossed_pawn?(move_params)
    color = pieces.find_by(startIndex: move_params[:startIndex]).color

    if pieces.find_by(startIndex: move_params[:startIndex]).pieceType == 'pawn'
      color == 'white' && move_params[:currentPosition][1] == '8' ||
      color == 'black' && move_params[:currentPosition][1] == '1'
    else
      false
    end
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
    captured_piece = handle_en_passant(move_params, piece) if en_passant?(move_params, piece)

    captured_piece.destroy if captured_piece.present?
  end

  def handle_en_passant(move_params, piece)
    captured_position = move_params[:currentPosition][0] + piece.currentPosition[1]
    captured_piece = pieces.find_by(currentPosition: captured_position)
  end

  def en_passant?(move_params, piece)
    [
      piece.pieceType == 'pawn',
      piece.currentPosition[0] != move_params[:currentPosition][0],
      pieces.find_by(currentPosition: move_params[:currentPosition]).blank?
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

  def send_new_move_email(piece, user)
    recipient = users.detect { |each_user| each_user != user }
    opponent_name = user.firstName
    MoveMailer.move(recipient, opponent_name, piece).deliver_later
  end

  def add_pieces
    json_pieces = JSON.parse(File.read(Rails.root + 'json/pieces.json'))

    json_pieces.deep_symbolize_keys.values.each do |json_piece|
      pieces.create(json_piece[:piece])
    end
  end
end
