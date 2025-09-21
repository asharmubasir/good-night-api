require "rails_helper"

RSpec.describe "V1::SleepTimelinesController#index", type: :request do
  include_context "a valid session"

  subject { get "/v1/sleep_timelines", params:, headers: auth_header }

  let(:params) { {} }
  let(:sleep_timeline_response) { json["sleep_timeline"] }

  let(:followee_1) { create(:user, name: "Jane") }
  let(:followee_2) { create(:user, name: "John") }

  let!(:follow_1) { create(:follow, follower: user, followee: followee_1) }
  let!(:follow_2) { create(:follow, follower: user, followee: followee_2) }

  let!(:sleep_record_1) { create(:sleep_record, user: followee_1, duration_in_minutes: 400) }
  let!(:sleep_record_2) { create(:sleep_record, user: followee_2, duration_in_minutes: 500) }
  let!(:sleep_record_3) { create(:sleep_record, user: followee_1, slept_at: (1.week + 1.day).ago, duration_in_minutes: 300) }

  context "with authenticated user" do
    it "returns a list of sleep timelines" do
      subject

      expect(response).to have_http_status(:ok)
    end

    it "returns the sleep timeline records for the last week" do
      subject

      expect(sleep_timeline_response).to contain_exactly(
        a_hash_including(
          "id" => sleep_record_1.id,
          "duration_in_minutes" => sleep_record_1.duration_in_minutes,
          "slept_at" => sleep_record_1.slept_at.iso8601,
          "woke_up_at" => sleep_record_1.woke_up_at.iso8601,
          "created_at" => sleep_record_1.created_at.iso8601,
          "user" => {
            "id" => followee_1.id,
            "name" => followee_1.name
          }
        ),
        a_hash_including(
          "id" => sleep_record_2.id,
          "duration_in_minutes" => sleep_record_2.duration_in_minutes,
          "slept_at" => sleep_record_2.slept_at.iso8601,
          "woke_up_at" => sleep_record_2.woke_up_at.iso8601,
          "created_at" => sleep_record_2.created_at.iso8601,
          "user" => {
            "id" => followee_2.id,
            "name" => followee_2.name
          }
        )
      )
    end

    it "orders the sleep timeline records by duration_in_minutes in DESC order" do
      subject

      expect(sleep_timeline_response.pluck("duration_in_minutes")).to eq(
        [ sleep_record_2.duration_in_minutes, sleep_record_1.duration_in_minutes ]
      )
    end
  end

  context "pagination" do
    let(:items) { nil }
    let(:page) { 1 }
    let(:params) { { page:, items: } }

    let(:pagination_response) { json["meta"]["pagination"] }

    let!(:sleep_records_1) { create_list(:sleep_record, 12, user: followee_1, duration_in_minutes: 100) }
    let!(:sleep_records_2) { create_list(:sleep_record, 15, user: followee_2, duration_in_minutes: 200) }

    it "returns at most 20 sleep timeline records by default" do
      subject

      expect(sleep_timeline_response.count).to eq(20)
      expect(pagination_response).to match(
        "page" => 1,
        "next" => 2,
        "count" => nil
      )
    end

    context "when items params is given" do
      let(:items) { 13 }

      it "returns paginated results and the correct next page availability" do
        subject

        expect(sleep_timeline_response.count).to eq(13)
        expect(pagination_response).to match(
          "page" => 1,
          "next" => 2,
          "count" => nil
        )
      end
    end

    context "when the given page is beyond the available results" do
      let(:page) { 50 }

      it "returns the empty results" do
        subject

        expect(sleep_timeline_response).to be_empty
        expect(pagination_response).to match(
          "page" => 50,
          "next" => nil,
          "count" => nil
        )
      end
    end
  end

  context "with unauthenticated user" do
    let(:auth_header) { nil }

    it "returns a valid 401 response" do
      subject

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
