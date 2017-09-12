class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@chess-mail.com'
  layout 'mailer'
end
