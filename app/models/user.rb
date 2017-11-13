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

  def send_confirmation_email
    url = "#{ENV['api_host']}/api/v1/users?token=#{token}"
    ConfirmationMailer.confirmation(self, url).deliver_later
  end
end
