require 'rails_helper'

RSpec.describe Archive, type: :model do
  let(:email) { Faker::Internet.email }
  let(:password) { "password" }
  let(:first_name) { Faker::Name.first_name }
  let(:last_name) { Faker::Name.last_name }

  it 'belongs_to a user' do
    user = User.create(
      email: email,
      password: password,
      firstName: first_name,
      lastName: last_name
    )

    archive = Archive.create(user_id: user.id)
    expect(archive.user).to eq user
  end
end
