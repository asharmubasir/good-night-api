require "rails_helper"

RSpec.shared_examples "invalid session" do
  it "returns a valid 400 response" do
    subject

    expect(response).to have_http_status(:bad_request)
  end

  it "returns an error message" do
    subject

    expect(json.dig("error", "detail")).to match_array(error_message)
  end
end

RSpec.describe "Sessions", type: :request do
  subject { post "/v1/sessions", params: }

  let(:params) { { name: user.name } }
  let(:user) { create(:user) }

  context "with valid params" do
    it "returns a valid 200 response" do
      subject

      expect(response).to have_http_status(:ok)
    end

    it "returns a JWT token" do
      subject

      expect(json["token"]).to be_present
    end

    context "when the user does not exist" do
      let(:params) { { name: "non-existent-user" } }
      let(:error_message) { [ "User not found, please check the name and try again" ] }

      it_behaves_like "invalid session"
    end
  end

  context "with invalid params" do
    let(:params) { {} }
    let(:error_message) { [ "param is missing or the value is empty or invalid: name" ] }

    it_behaves_like "invalid session"
  end
end
