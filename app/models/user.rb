class User < ApplicationRecord
  has_secure_password
  validates_presence_of :email, :firstName, :lastName
  validates_uniqueness_of :email

  has_many :user_games
  has_many :games, through: :user_games

  before_save :hash_email, :downcase_email

  def hash_email
    self.hashed_email = Digest::MD5.hexdigest(email.downcase.strip)
  end

  def downcase_email
    self.email = email.downcase
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
        included: user_games
      }
    }
  end

  def user_games
    unique_games = (Game.challenged_games(email).not_archived + games.not_archived)
                   .sort_by(&:created_at).uniq
                   
    Game.serialize_games(unique_games, email)[:data]
  end

  def send_confirmation_email
    url = "#{ENV['api_host']}/api/v1/users?token=#{token}"
    ConfirmationMailer.confirmation(self, url).deliver_later
  end
end
