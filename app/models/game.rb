class Game < ApplicationRecord
  has_many :user_games
  has_many :users, through: :user_games
  has_many :game_pieces
  has_many :pieces, through: :game_pieces

  validates_presence_of :challengedName, :challengedEmail, :challengerColor

  scope :not_archived, -> { where(archived: false) }
  scope :challenged_games, ->(email) { where(challengedEmail: email) }

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
        isChallenger: is_challenger?(user_email),
        outcome: outcome
      },
      included: pieces.map(&:serialize_piece)
    }
  end

  def is_challenger?(email)
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
    end
  end

  def add_challenged_player
    user = User.find_by(email: challengedEmail)
    users << user if user
  end

  def handle_resign(user)
    winner = current_player_color(user) == 'white' ? 'black wins!' : 'white wins!'
    update(outcome: winner)
  end

  def send_challenge_email(user)
    challenged_player = User.find_by(email: challengedEmail)
    token = challenged_player ? challenged_player.token : ''

    ChallengeMailer.challenge(
      "#{user.firstName.capitalize} #{user.lastName.capitalize}",
      challengedName,
      challengedEmail,
      "#{ENV['api_host']}/api/v1/games/accept/#{id}?token=#{token}&from_email=true"
    ).deliver_later
  end

  def send_new_move_email(piece, user)
    recipient = users.detect { |each_user| each_user != user }
    opponent_name = user.firstName
    MoveMailer.move(recipient, opponent_name, piece).deliver_later
  end
end
