# == Schema Information
#
# Table name: sleep_records
#
#  id                  :bigint           not null, primary key
#  duration_in_minutes :integer
#  slept_at            :datetime
#  woke_up_at          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  user_id             :bigint           not null
#
# Indexes
#
#  index_sleep_records_on_duration_in_minutes_desc  (duration_in_minutes) WHERE (duration_in_minutes IS NOT NULL)
#  index_sleep_records_on_user_id                   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe SleepRecord, type: :model do
  it "is valid with valid attributes" do
    expect(build(:sleep_record)).to be_valid
  end
end
