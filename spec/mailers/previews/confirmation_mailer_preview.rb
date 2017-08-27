# Preview all emails at http://localhost:3001/rails/mailers/confirmation_mailer
class ConfirmationMailerPreview < ActionMailer::Preview
  def confirmation_preview
    user = User.new(email: 'bob@jones.com', password: 'password', firstName: 'bob', lastName: 'jones', token: 'token')
    url = "#{ENV['api_host']}/api/v1/users?token=#{user.token}"
    ConfirmationMailer.confirmation(user, url)
  end
end
