class User < ApplicationRecord
  has_secure_password
  validates_presence_of :email, :firstName, :lastName
  validates_uniqueness_of :email

  has_many :user_games
  has_many :games, through: :user_games
  has_many :archives

  before_save :hash_email, :downcase_email
  after_commit :add_games, on: :create

  def hash_email
    self.hashed_email = Digest::MD5.hexdigest(email.downcase.strip)
  end

  def downcase_email
    self.email = email.downcase
  end

  def add_games
    self.games = Game.where(challengedEmail: email)
  end

  def serialize_user
    {
      data: {
        type: 'user',
        id: id,
        attributes: {
          hashed_email: hashed_email,
          token: token,
          firstName: firstName,
          lastName: lastName
        },
        included: serialized_user_games
      }
    }
  end

  def serialized_user_games(page = 1, quantity = 6)
    page = 1 if page.blank?

    archived_game_ids = archives.pluck(:game_id)
    user_games = games.not_archived(archived_game_ids)
                      .order(created_at: :desc)
                      .offset(calculate_offset(page, quantity))
                      .limit(quantity)

    user_games.map { |user_game| GameSerializer.serialize(user_game, email) }
    # GameSerializer.serialize_games(user_games, email)[:data]
  end

  def calculate_offset(page, quantity)
    (page.to_i - 1) * quantity.to_i
  end

  def send_confirmation_email
    url = "#{ENV['api_host']}/api/v1/users?token=#{token}"
    ConfirmationMailer.confirmation(self, url).deliver_later
  end
end
