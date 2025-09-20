require 'rails_helper'

RSpec.describe SleepRecord, type: :model do
  it "is valid with valid attributes" do
    expect(build(:sleep_record)).to be_valid
  end
end
