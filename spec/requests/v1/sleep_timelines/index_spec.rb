require "rails_helper"

RSpec.describe "V1::SleepTimelinesController#index", type: :request do
  include_context "a valid session"

  subject { get "/v1/sleep_timelines", headers: auth_header }

  context "with authenticated user" do
    it "returns a list of sleep timelines" do
      subject

      expect(response).to have_http_status(:ok)
    end
  end
end
