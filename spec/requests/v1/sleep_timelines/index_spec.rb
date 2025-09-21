require "rails_helper"

RSpec.describe "V1::SleepTimelinesController#index", type: :request do
  let(:user) { create(:user) }
  let(:jwt_token) { Auth::Jwt.new.encode(user_id: user.id) }

  it "returns a list of sleep timelines" do
    get "/v1/sleep_timelines", headers: { "Authorization" => "Bearer #{jwt_token}" }
    expect(response).to have_http_status(:ok)
  end
end
