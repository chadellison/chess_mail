class User < ApplicationRecord
  has_secure_password
  validates_presence_of :email, :firstName, :lastName
  validates_uniqueness_of :email

  has_many :user_games
  has_many :games, through: :user_games

  before_save :hash_email

  def hash_email
    self.hashed_email = Digest::MD5.hexdigest(email.downcase.strip)
  end

  def serialize_user
    user_games = (Game.where(challengedEmail: email) + games).sort_by(&:created_at)
    serialized_games = Game.serialize_games(user_games, email)

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
        included: serialized_games[:data]
      }
    }
  end

  def send_confirmation_email
    url = "#{ENV['api_host']}/api/v1/users?token=#{token}"
    ConfirmationMailer.confirmation(self, url).deliver_later
  end
end
