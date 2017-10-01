require "rails_helper"

RSpec.describe MoveMailer, type: :mailer do
  let(:recipient) {
    User.create(
      firstName: Faker::Name.first_name,
      lastName: Faker::Name.last_name,
      email: Faker::Internet.email,
      password: 'password'
    )
  }

  let(:challenged_name) { Faker::Name.name }
  let(:piece) {
    Piece.create(
      currentPosition: 'a2',
      pieceType: 'knight',
      startIndex: Faker::Number.number(2)
    )
  }

  let(:mail) { MoveMailer.move(recipient, challenged_name, piece) }

  it 'rendes a to' do
    expect(mail.to).to eq [recipient.email]
  end

  it 'rendes a to' do
    subject = 'A new move has been made'

    expect(mail.subject).to eq subject
  end
end
