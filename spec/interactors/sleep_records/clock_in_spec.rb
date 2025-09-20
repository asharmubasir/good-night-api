require "rails_helper"

RSpec.shared_examples "failed clock in" do
  it "fails and returns an error message" do
    expect(subject).to be_failure
    expect(subject.error).to match_array(error_message)
  end

  it "does not clock in user" do
    expect { subject }.to change(SleepRecord, :count).by(0)
  end
end

RSpec.describe SleepRecords::ClockIn do
  subject { described_class.call(user:, clock_time: clock_in_time) }

  let(:user) { create(:user) }
  let(:clock_in_time) { Time.current }

  context "with valid params" do
    it "clocks in user" do
      expect { subject }.to change(SleepRecord, :count).by(1)

      expect(subject.sleep_record).to have_attributes(
        user: user,
        slept_at: be_within(1.second).of(clock_in_time),
      )
    end

    context "when the user has an active clock in" do
      let!(:sleep_record) { create(:sleep_record, :active, user:) }
      let(:error_message) { [ "You already have an active clock in, please clock out first" ] }

      it_behaves_like "failed clock in"
    end
  end

  context "with invalid params" do
    context "when user is not present" do
      let(:user) { nil }
      let(:error_message) { [ "User can't be blank" ] }

      it_behaves_like "failed clock in"
    end

    context "when clock time is not present" do
      let(:clock_in_time) { nil }
      let(:error_message) { [ "Clock time can't be blank" ] }

      it_behaves_like "failed clock in"
    end
  end

  context "with unsuccessful create" do
    let(:error_message) { [ "Record invalid" ] }

    before do
      allow(user.sleep_records).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
    end

    it_behaves_like "failed clock in"
  end
end
