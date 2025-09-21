module SleepRecords
  class Timeline
    def initialize(user)
      @user = user
    end

    def call
      user.followings
        .joins(:sleep_records)
        .where(sleep_records: { slept_at: 1.week.ago..Time.current })
        .where.not(sleep_records: { duration_in_minutes: nil })
        .select("users.id as user_id, users.name as user_name, sleep_records.*")
        .order("sleep_records.duration_in_minutes DESC")
    end

    private attr_reader :user
  end
end
