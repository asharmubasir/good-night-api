require "rails_helper"

RSpec.describe "V1::SleepRecordsController", type: :request do
  include_context "a valid session"

  subject { get "/v1/sleep_records", params:, headers: auth_header }

  let(:sleep_records_response) { json["sleep_records"] }
  let(:params) { {} }

  context "with authenticated user" do
    let!(:sleep_record_1) { create(:sleep_record, user:) }
    let!(:sleep_record_2) { create(:sleep_record, user:) }

    it "returns a valid 200 response" do
      subject

      expect(response).to have_http_status(:ok)
    end

    it "returns the clock-in records for the current user" do
      subject

      expect(sleep_records_response.count).to eq(2)
    end

    it "orders the clock-in records by created_at in DESC order" do
      subject

      expect(sleep_records_response.pluck("created_at")).to eq(
        [
          sleep_record_2.created_at.iso8601,
          sleep_record_1.created_at.iso8601
        ]
      )
    end

    it "returns the sleep record attributes" do
      subject

      expect(sleep_records_response).to contain_exactly(
        a_hash_including(
          "id" => sleep_record_1.id,
          "slept_at" => sleep_record_1.slept_at.iso8601,
          "woke_up_at" => sleep_record_1.woke_up_at.iso8601,
          "created_at" => sleep_record_1.created_at.iso8601,
          "duration_in_minutes" => sleep_record_1.duration_in_minutes
        ),
        a_hash_including(
          "id" => sleep_record_2.id,
          "slept_at" => sleep_record_2.slept_at.iso8601,
          "woke_up_at" => sleep_record_2.woke_up_at.iso8601,
          "created_at" => sleep_record_2.created_at.iso8601,
          "duration_in_minutes" => sleep_record_2.duration_in_minutes
        )
      )
    end
  end

  context "pagination" do
    let(:items) { nil }
    let(:page) { 1 }
    let(:params) { { page:, items: } }

    let(:pagination_response) { json["meta"]["pagination"] }

    let!(:sleep_records) { create_list(:sleep_record, 23, user:) }

    it "returns at most 20 clock-in records by default" do
      subject

      expect(sleep_records_response.count).to eq(20)
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

        expect(sleep_records_response.count).to eq(13)
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

        expect(sleep_records_response).to be_empty
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
