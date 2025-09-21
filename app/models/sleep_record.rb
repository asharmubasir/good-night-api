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
#  idx_sleep_records_timeline_optimized             (user_id,slept_at,duration_in_minutes DESC) WHERE (duration_in_minutes IS NOT NULL)
#  index_active_sleep_records_on_user               (user_id,woke_up_at) UNIQUE WHERE (woke_up_at IS NULL)
#  index_sleep_records_on_duration_in_minutes_desc  (duration_in_minutes) WHERE (duration_in_minutes IS NOT NULL)
#  index_sleep_records_on_user_id                   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class SleepRecord < ApplicationRecord
  belongs_to :user

  scope :active, -> { where(woke_up_at: nil) }
end
