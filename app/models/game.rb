class Game < ApplicationRecord
  has_many :user_games
  has_many :users, through: :user_games
  has_many :game_pieces
  has_many :pieces, through: :game_pieces

  class << self
    def handle_game_creation(user, game_params)
      if game_params[:challengedName].present? && game_params[:challengedEmail].present?
        handle_challenge(user, game_params)
      else
        { error: 'Player name and player email must be filled.' }
      end
    end

    def handle_challenge(user, game_params)
      if user.games.find_by(challenged_email: game_params[:challengedEmail]).present?
        { error: 'A game or challenge is already in progress for this person' }
      else
        game = user.games.create
        game.setup(user, game_params)
        game
      end
    end

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
        opponentGravatar: opponent_gravatar
      },
      included: pieces.map(&:serialize_piece)
    }
  end

  def current_player_color(email)
    if challenged_email == email
      player_color == 'white' ? 'black' : 'white'
    else
      player_color
    end
  end

  def current_opponent_name(email)
    if challenged_email == email
      users.where.not(email: email).first.firstName
    else
      challenged_name
    end
  end

  def current_opponent_email(email)
    if challenged_email == email
      users.where.not(email: email).first.email
    else
      challenged_email
    end
  end


  def setup(user, game_params)
    if game_params[:challengePlayer].to_s == 'true'
      add_challenged_player(game_params[:challengedEmail])
      send_challenge_email(user, game_params)
    end
    update(player_color: game_params[:playerColor])
  end

  def add_challenged_player(challenged_email)
    update(challenged_email: challenged_email)

    user = User.find_by(email: challenged_email)
    users << user if user
  end

  def send_challenge_email(user, game_params)
    full_name = "#{user.firstName.capitalize} #{user.lastName.capitalize}"
    challenged_player = User.find_by(email: game_params[:challengedEmail])
    token = ''
    token = challenged_player.token if challenged_player

    ChallengeMailer.challenge_player(
      full_name,
      game_params[:challengedName],
      game_params[:challengedEmail],
      "#{ENV['api_host']}/api/v1/games/accept/#{id}?token=#{token}",
      ENV['host']
    )
  end
end
