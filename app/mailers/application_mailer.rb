class ApplicationMailer < ActionMailer::Base
  default from: 'from@chess-mail.com'
  layout 'mailer'
end
