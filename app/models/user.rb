class User < ApplicationRecord
  has_secure_password
  validates_presence_of :email, :firstName, :lastName
  validates_uniqueness_of :email

  has_many :user_games
  has_many :games, through: :user_games

  before_save :hash_email

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
        }
      }
    }
  end

  def hash_email
    self.hashed_email = Digest::MD5.hexdigest(email.downcase.strip)
  end
end
