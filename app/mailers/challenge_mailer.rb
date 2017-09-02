class ChallengeMailer < ApplicationMailer
  default from: "no-reply@beerproject.com"

  def challenge_player(player_name, challenged_name, challenged_email, accept, url)
    @player_name = player_name
    @challenged_name = challenged_name
    @challenged_email = challenged_email
    @accept = accept
    @url = url
    mail(to: challenged_email.email, subject: "You have been challenged to a game of chess")
  end
end
