class ChallengeMailer < ApplicationMailer
  def challenge(player_name, challenged_name, challenged_email, accept)
    @player_name = player_name
    @challenged_name = challenged_name
    @challenged_email = challenged_email
    @accept = accept
    @host = ENV['host']
    mail(to: challenged_email, subject: "You have been challenged to a game of chess")
  end
end
