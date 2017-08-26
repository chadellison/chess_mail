require 'rails_helper'

RSpec.describe Api::V1::AuthenticationController, type: :controller do
  describe "#authenticate" do
    context "with the proper email and password" do
      let(:email) { Faker::Internet.email }

      let!(:user) { User.create(email: email, password: "password", approved: true) }

      let(:params) { { credentials: { email: email, password: "password" } } }

      it "returns the user's token and hashed_email, but not the email or password" do
        post :create, params: params, format: :json

        expect(response.status).to eq 201
        expect(JSON.parse(response.body)["data"]["attributes"]["hashed_email"]).to eq user.hashed_email
        expect(JSON.parse(response.body)["data"]["attributes"]["token"]).to be_present
        expect(JSON.parse(response.body)["data"]["attributes"]["email"]).not_to be_present
        expect(JSON.parse(response.body)["data"]["attributes"]["password"]).not_to be_present
      end
    end

    context "with improper credentials" do
      let(:email) { Faker::Internet.email }
      let!(:user) { User.create(email: email, password: "password") }
      let(:bad_password) { Faker::Name.name }
      let(:params) { { credentials: { email: email, password: bad_password } } }

      it "returns a 404 status and an error" do
        get :create, params: params, format: :json

        expect(response.status).to eq 404
        expect(JSON.parse(response.body)["errors"]).to eq "Invalid Credentials"
      end
    end

    context "when the user is not approved" do
      let(:email) { Faker::Internet.email }
      let!(:user) { User.create(email: email, password: "password") }
      let(:params) { { credentials: { email: email, password: "password" } } }

      it "returns a 404 status and an error" do
        get :create, params: params, format: :json

        expect(response.status).to eq 404
        expect(JSON.parse(response.body)["errors"]).to eq "Invalid Credentials"
      end
    end

    context "with an uppercase email" do
      let(:email) { Faker::Internet.email }
      let!(:user) { User.create(email: email,
                                password: "password",
                                approved: true) }

      let(:params) { { credentials: { email: email.upcase,
                                      password: "password" } } }

      it "finds the email" do
        post :create, params: params, format: :json

        expect(response.status).to eq 201
        expect(JSON.parse(response.body)["data"]["attributes"]["hashed_email"]).to eq user.hash_email
        expect(JSON.parse(response.body)["data"]["attributes"]["token"]).to be_present
      end
    end
  end
end
