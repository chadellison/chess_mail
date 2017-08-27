# Preview all emails at http://localhost:3000/rails/mailers/confirmation_mailer
class ConfirmationMailerPreview < ActionMailer::Preview
  def confirmation_preview
    user = User.new(email: 'bob@jones.com', password: 'password', firstName: 'bob', lastName: 'jones')
    ConfirmationMailer.confirmation(user)
  end
end
