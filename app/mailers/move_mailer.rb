class MoveMailer < ApplicationMailer
  default from: 'no-reply@chess-mail.com'

  def move(recipient, opponent_name, piece)
    @recipient     = recipient
    @opponent_name = opponent_name
    @piece         = piece
    @host          = ENV['host']

    mail(to: recipient.email, subject: 'A new move has been made')
  end
end
