module SleepRecords
  class ClockIn < ApplicationAction
    delegate :user, :clock_time, to: :context, private: true

    validates :user, :clock_time, presence: true
    validate :active_sleep_record, if: -> { user.present? }

    def call
      validate_params!

      context.sleep_record = user.sleep_records.create!(slept_at: clock_time)
    rescue ActiveRecord::RecordInvalid => e
      context.fail!(error: [ e.message ])
    end

    private

    def active_sleep_record
      errors.add(:base, I18n.t("errors.active_sleep_record")) if user.sleep_records.active.any?
    end
  end
end
