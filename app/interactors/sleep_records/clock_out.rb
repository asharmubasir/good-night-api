module SleepRecords
  class ClockOut < ApplicationAction
    delegate :user, :clock_time, to: :context, private: true

    validates :user, :clock_time, presence: true
    validate :require_active_sleep_record, if: -> { user.present? && clock_time.present? }
    validate :ensure_clock_time_after_slept_at, if: -> { user.present? && clock_time.present? && sleep_record.present? }

    def call
      validate_params!

      context.sleep_record = sleep_record.update!(woke_up_at: clock_time, duration_in_minutes:)
    rescue ActiveRecord::RecordInvalid => e
      context.fail!(error: [ e.message ])
    end

    private

    def sleep_record
      @_sleep_record ||= user.active_sleep_record
    end

    def duration_in_minutes
      ((clock_time - sleep_record.slept_at) / 60).to_i
    end

    def require_active_sleep_record
      errors.add(:base, I18n.t("errors.not_clocked_in")) unless sleep_record.present?
    end

    def ensure_clock_time_after_slept_at
      errors.add(:base, I18n.t("errors.invalid_clock_time")) unless clock_time > sleep_record.slept_at
    end
  end
end
