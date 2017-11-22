class Game < ApplicationRecord
  has_many :user_games
  has_many :users, through: :user_games
  has_many :pieces, dependent: :delete_all
  has_many :moves, dependent: :delete_all

  validates_presence_of :challengedName, :challengedEmail, :challengerColor

  after_commit :add_pieces, on: :create

  scope :not_archived, ->(archived_game_ids) { where.not(id: archived_game_ids) }
  scope :similar_games, (lambda do |move_signature|
    where('move_signature LIKE ?', "#{move_signature}%").where(robot: true)
  end)
  scope :winning_games, ->(win, color) { where(outcome: win, challengerColor: [nil, color]) }
  scope :drawn_games, -> { where(outcome: 0) }

  include NotationLogic
  include AiLogic
  include GameLogic

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
    if robot.blank?
      add_challenged_player
      send_challenge_email(user)
    else
      update(
        pending: false,
        challengedEmail: Faker::Internet.email,
        challengedName: Faker::Name.first_name
      )
      ai_move if challengerColor == 'black'
    end
  end

  def add_challenged_player
    user = User.find_by(email: challengedEmail)
    users << user if user
  end

  def handle_resign(user)
    if current_player_color(user.email) == 'white'
      update(outcome: -1)
    else
      update(outcome: 1)
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
    if training_game.blank?
      json_pieces = JSON.parse(File.read(Rails.root + 'json/pieces.json'))

      json_pieces.deep_symbolize_keys.values.each do |json_piece|
        pieces.create(json_piece[:piece])
      end
    end
  end
end
