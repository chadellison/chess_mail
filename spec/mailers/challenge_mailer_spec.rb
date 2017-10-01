require 'rails_helper'

RSpec.describe ChallengeMailer, type: :mailer do
  describe '#challenge' do
    let(:name) { Faker::Name.name }
    let(:challenged_name) { Faker::Name.name }
    let(:challenged_email) { Faker::Internet.email }
    let(:accept) { 'url' }

    let(:mail) { ChallengeMailer.challenge(name, challenged_name, challenged_email, accept) }

    it 'rendes a to' do
      expect(mail.to).to eq [challenged_email]
    end

    it 'rendes a to' do
      subject = 'You have been challenged to a game of chess'

      expect(mail.subject).to eq subject
    end
  end
end
