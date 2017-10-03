class MoveMailer < ApplicationMailer
  def move(recipient, opponent_name, piece_position, piece_type)
    @recipient      = recipient
    @opponent_name  = opponent_name
    @piece_position = piece_position
    @piece_type     = piece_type
    @host           = ENV['host']

    mail(to: recipient.email, subject: 'A new move has been made')
  end
end
