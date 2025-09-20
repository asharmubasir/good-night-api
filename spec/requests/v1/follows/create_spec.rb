require "rails_helper"

RSpec.describe "V1::Users::Follows", type: :request do
  include_context "a valid session"

  subject { post "/v1/users/follow", headers: auth_header, params: params.to_json }

  let(:followee) { create(:user, name: "Jane") }
  let(:params) { { followee_id: followee.id } }

  context "with authenticated user" do
    it "returns a 200 status code" do
      subject

      expect(response).to have_http_status(:created)
    end

    it "follows the followee" do
      expect { subject }.to change(Follow, :count).by(1)

      expect(Follow.last).to have_attributes(
        follower_id: user.id,
        followee_id: followee.id
      )
    end

    it "returns the follow attributes" do
      subject

      json_follow = json["follow"]
      expect(json_follow["id"]).to be_present
      expect(json_follow["follower"]["id"]).to eq(user.id)
      expect(json_follow["followee"]["id"]).to eq(followee.id)
      expect(json_follow["created_at"]).to be_present
    end

    context "when user is following themselves" do
      let(:followee) { user }

      it "returns a 422 status code" do
        subject

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns an error message" do
        subject

        expect(json.dig("error", "detail")).to match_array([ "You cannot follow or unfollow yourself" ])
      end
    end

    context "when user is already following the followee" do
      let!(:follow) { create(:follow, follower: user, followee: followee) }

      it "returns a 422 status code" do
        subject

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns an error message" do
        subject

        expect(json.dig("error", "detail")).to match_array([ "You already follow this user" ])
      end
    end
  end

  context "with unauthenticated user" do
    let(:auth_header) { nil }

    it "returns a 401 status code" do
      subject

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
