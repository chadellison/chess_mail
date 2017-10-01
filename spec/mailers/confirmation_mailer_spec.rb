require 'rails_helper'

RSpec.describe ConfirmationMailer, type: :mailer do
  let(:user) {
    User.create(
      firstName: Faker::Name.first_name,
      lastName: Faker::Name.last_name,
      email: Faker::Internet.email,
      password: 'password'
    )
  }

  let(:url) { 'url' }
  let(:mail) { ConfirmationMailer.confirmation(user, url) }

  it 'rendes a to' do
    expect(mail.to).to eq [user.email]
  end

  it 'rendes a to' do
    subject = 'confirm your account'

    expect(mail.subject).to eq subject
  end
end
