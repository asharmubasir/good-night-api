require "rails_helper"

RSpec.shared_examples "failed unfollow" do
  it "fails and returns an error message" do
    expect(subject).to be_failure
    expect(subject.error).to match_array(error_message)
  end

  it "does not unfollow the followee" do
    expect { subject }.to change(Follow, :count).by(0)
  end
end

RSpec.describe Users::Unfollow do
  subject { described_class.call(user:, followee:) }

  let(:user) { create(:user, name: "Tom") }
  let(:followee) { create(:user, name: "Jimmy") }

  context "with valid params" do
    let!(:follow) { create(:follow, follower: user, followee:) }

    it "unfollows the followee" do
      expect { subject }.to change(Follow, :count).by(-1)
      expect { follow.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "when user is unfollowing themselves" do
      let(:followee) { user }
      let(:error_message) { [ "You cannot follow or unfollow yourself" ] }

      it_behaves_like "failed unfollow"
    end

    context "when the user is not following the followee" do
      let(:error_message) { [ "You are not following this user" ] }

      let!(:follow) { nil }

      it_behaves_like "failed unfollow"
    end
  end

  context "with invalid params" do
    context "when the user is not present" do
      let(:user) { nil }
      let(:error_message) { [ "User can't be blank" ] }

      it_behaves_like "failed unfollow"
    end

    context "when the followee is not present" do
      let(:followee) { nil }
      let(:error_message) { [ "Followee can't be blank" ] }

      it_behaves_like "failed unfollow"
    end
  end

  context "with unsuccessful destroy" do
    let(:error_message) { [ "Failed to destroy the record" ] }

    let!(:follow) { create(:follow, follower: user, followee:) }

    before do
      allow_any_instance_of(Follow).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed)
    end

    it_behaves_like "failed unfollow"
  end
end
