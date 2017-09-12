class ConfirmationMailer < ApplicationMailer
  def confirmation(new_user, url)
    @new_user = new_user
    @url = url
    mail(to: new_user.email, subject: 'confirm your account')
  end
end
