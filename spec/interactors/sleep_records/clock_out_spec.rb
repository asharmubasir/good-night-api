require "rails_helper"

RSpec.shared_examples "failed clock out" do
  it "fails and returns an error message" do
    expect(subject).to be_failure
    expect(subject.error).to match_array(error_message)
  end
end

RSpec.describe SleepRecords::ClockOut do
  subject { described_class.call(user:, clock_time: clock_out_time) }

  let(:clock_in_time) { Time.current }
  let(:clock_out_time) { Time.current + 6.hours }
  let(:user) { create(:user) }

  let!(:active_sleep_record) { create(:sleep_record, :active, user:, slept_at: clock_in_time) }

  context "with valid params" do
    it "clocks out user and updates the duration of the sleep record in minutes" do
      expect { subject }
        .to change { active_sleep_record.reload.duration_in_minutes }.to(360)
        .and change { active_sleep_record.woke_up_at }.to be_within(1.second).of(clock_out_time)
    end

    context "when user does not have an active sleep record" do
      let(:error_message) { [ "You don't have an active clock in, please clock in first" ] }

      let!(:active_sleep_record) { nil }

      it_behaves_like "failed clock out"
    end
  end

  context "with invalid params" do
    context "when clock time is not present" do
      let(:clock_out_time) { nil }
      let(:error_message) { [ "Clock time can't be blank" ] }

      it_behaves_like "failed clock out"
    end

    context "when clock time is not after the clock in time" do
      let(:clock_out_time) { clock_in_time - 1.hour }
      let(:error_message) { [ "The clock out time must be after the clock in time" ] }

      it_behaves_like "failed clock out"
    end

    context "when user is not present" do
      let(:user) { nil }
      let(:error_message) { [ "User can't be blank" ] }

      let!(:active_sleep_record) { nil }

      it_behaves_like "failed clock out"
    end
  end
end
