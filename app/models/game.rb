class Game < ApplicationRecord
  has_many :user_games
  has_many :users, through: :user_games
  has_many :pieces
  has_many :moves

  validates_presence_of :challengedName, :challengedEmail, :challengerColor

  after_commit :add_pieces, on: :create

  scope :not_archived, ->(archived_game_ids) { where.not(id: archived_game_ids) }
  scope :similar_game, (lambda do |move_signature|
    where('move_signature LIKE ?', "#{move_signature}%").where.not(human: true)
  end)
  scope :winning_game, ->(color) { where(outcome: color + ' wins') }
  scope :drawn_game, -> { where(outcome: 'draw') }

  include NotationLogic
  include AiLogic
  include GameLogic

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
