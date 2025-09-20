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
FactoryBot.define do
  factory :sleep_record do
    association :user
    slept_at { "2025-09-20 10:01:45" }
    woke_up_at { "2025-09-20 10:02:45" }
    duration_in_minutes { 1 }
  end

  trait :active do
    woke_up_at { nil }
  end
end
