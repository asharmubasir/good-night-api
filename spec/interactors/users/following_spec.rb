require "rails_helper"

RSpec.shared_examples "failed following" do
  it "fails and returns an error message" do
    expect(subject).to be_failure
    expect(subject.error).to match_array(error_message)
  end

  it "does not follow the user" do
    expect { subject }.to change(Follow, :count).by(0)
  end
end

RSpec.describe Users::Following do
  subject { described_class.call(user:, followee:) }

  let(:user) { create(:user, name: "John") }
  let(:followee) { create(:user, name: "Jane") }

  context "with valid params" do
    it "follows the user" do
      expect { subject }.to change(Follow, :count).by(1)

      expect(subject.follow).to have_attributes(
        follower_id: user.id,
        followee_id: followee.id
      )
    end

    context "when user is following themselves" do
      let(:followee) { user }
      let(:error_message) { [ "You cannot follow yourself" ] }

      it_behaves_like "failed following"
    end

    context "when user is already following the followee" do
      let!(:follow) { create(:follow, follower: user, followee: followee) }
      let(:error_message) { [ "You already follow this user" ] }

      it_behaves_like "failed following"
    end
  end

  context "with invalid params" do
    context "when user is not present" do
      let(:user) { nil }
      let(:error_message) { [ "User can't be blank" ] }

      it_behaves_like "failed following"
    end

    context "when followee is not present" do
      let(:followee) { nil }
      let(:error_message) { [ "Followee can't be blank" ] }

      it_behaves_like "failed following"
    end
  end

  context "with unsuccessful create" do
    let(:error_message) { [ "Record invalid" ] }

    before do
      allow(Follow).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
    end

    it_behaves_like "failed following"
  end
end
