require "rails_helper"

RSpec.describe "V1::Users::Follows", type: :request do
  include_context "a valid session"

  subject { delete "/v1/users/unfollow", params: params.to_json, headers: auth_header }

  let(:followee) { create(:user, name: "Jane") }
  let(:params) {
    {
      followee_id: followee.id
    }
  }

  context "with authenticated user" do
    let!(:follow) { create(:follow, follower: user, followee: followee) }

    it "returns a 204 status code" do
      subject

      expect(response).to have_http_status(:no_content)
    end

    it "unfollows the followee" do
      expect { subject }.to change(Follow, :count).by(-1)
      expect { follow.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "when user is not following the followee" do
      let!(:follow) { nil }

      it "returns a 422 status code" do
        subject

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns an error message" do
        subject

        expect(json.dig("error", "detail")).to match_array([ "You are not following this user" ])
      end
    end

    context "when user is unfollowing themselves" do
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
  end

  context "with unauthenticated user" do
    let(:auth_header) { nil }

    it "returns a 401 status code" do
      subject

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
