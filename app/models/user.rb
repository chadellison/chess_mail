class User < ApplicationRecord
  has_secure_password
  validates_presence_of :email
  validates_uniqueness_of :email

  before_save :hash_email

  def serialize_user
    {
      type: 'user',
      id: id,
      attributes: {
        hashed_email: hashed_email,
        token: token
      }
    }
  end

  def hash_email
    self.hashed_email = Digest::MD5.hexdigest(email.downcase.strip)
  end
end
