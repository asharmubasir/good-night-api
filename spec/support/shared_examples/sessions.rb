RSpec.shared_examples "a valid session" do
  let(:user) { create(:user) }
  let(:token) { Auth::Jwt.new.encode(user_id: user.id) }

  let(:auth_header) {
    {
      "Content-Type" => "application/json",
      "Accept" => "application/json",
      "Authorization" => "Bearer #{token}"
    }
  }
end
