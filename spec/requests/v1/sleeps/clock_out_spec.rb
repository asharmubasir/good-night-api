require "rails_helper"

RSpec.describe "V1::SleepRecordsController", type: :request do
  include_context "a valid session"

  subject { post "/v1/sleep_records/clock_out", headers: auth_header }

  let(:current_time) { "2025-05-03T10:00:00Z" }
  let(:clock_in_time) { current_time.to_time - 6.hours }
  let(:sleep_record_response) { json["sleep_record"] }
  let(:user) { create(:user) }

  let!(:active_sleep_record) { create(:sleep_record, :active, user:, slept_at: clock_in_time) }

  before do
    travel_to(current_time)
  end

  context "with authenticated user" do
    it "returns a valid 201 response" do
      subject

      expect(response).to have_http_status(:ok)
    end

    it "clocks out the user and updates the duration of the sleep record in minutes" do
      expect { subject }
        .to change { active_sleep_record.reload.duration_in_minutes }.to(360)
        .and change { active_sleep_record.woke_up_at }.to be_within(1.second).of(current_time.to_time)
    end

    it "returns the sleep record attributes" do
      subject

      expect(sleep_record_response["id"]).to eq(user.sleep_records.last.id)
      expect(sleep_record_response["slept_at"]).to be_present
      expect(sleep_record_response["woke_up_at"]).to be_present
      expect(sleep_record_response["created_at"]).to be_present
      expect(sleep_record_response["duration_in_minutes"]).to eq(360)
    end

    context "when user does not have an active sleep record" do
      let!(:active_sleep_record) { nil }

      it "returns a valid 422 response" do
        subject

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns error message" do
        subject

        expect(json.dig("error", "detail")).to match_array([ "You don't have an active clock in, please clock in first" ])
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
