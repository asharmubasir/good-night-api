class SleepRecord < ApplicationRecord
  belongs_to :user

  scope :active, -> { where(woke_up_at: nil) }
end
