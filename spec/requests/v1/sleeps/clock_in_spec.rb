require "rails_helper"

RSpec.describe "SleepRecords", type: :request do
  include_context "a valid session"

  subject { post "/v1/sleep_records/clock_in", headers: auth_header }

  let(:current_time) { "2025-05-03T15:54:33Z" }
  let(:sleep_record_response) { json["sleep_record"] }

  before do
    travel_to(current_time)
  end

  context "with authenticated user" do
    it "returns a valid 201 response" do
      subject

      expect(response).to have_http_status(:created)
    end

    it "clocks in the user" do
      expect { subject }.to change(SleepRecord, :count).by(1)

      expect(SleepRecord.last).to have_attributes(
        user: user,
        slept_at: be_within(1.second).of(current_time.to_time),
      )
    end

    it "returns the sleep record attributes" do
      subject

      expect(sleep_record_response["id"]).to eq(user.sleep_records.last.id)
      expect(sleep_record_response["slept_at"]).to eq(current_time)
      expect(sleep_record_response["woke_up_at"]).to be_nil
      expect(sleep_record_response["created_at"]).to eq(current_time)
    end

    context "when user has an active sleep record" do
      let!(:sleep_record) { create(:sleep_record, :active, user:) }

      it "returns a valid 400 response" do
        subject

        expect(response).to have_http_status(:bad_request)
      end

      it "returns error message" do
        subject

        expect(json.dig("error", "detail")).to match_array([ "You already have an active clock in, please clock out first" ])
      end
    end
  end

  context "with unauthenticated user" do
    let(:token) { nil }

    it "returns a valid 401 response" do
      subject

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns error message" do
      subject

      expect(json.dig("error", "detail")).to match_array([ "Token is invalid" ])
    end
  end
end
