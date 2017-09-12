class ConfirmationMailer < ApplicationMailer
  default from: 'no-reply@chess-mail.com'

  def confirmation(new_user, url)
    @new_user = new_user
    @url = url
    mail(to: new_user.email, subject: 'confirm your account')
  end
end
