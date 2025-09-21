module SleepRecords
  class Timeline
    def initialize(user)
      @user = user
    end

    def call
      user.followings
        .joins(:sleep_records)
        .where(sleep_records: {
          slept_at: 1.week.ago..Time.current,
          duration_in_minutes: 0..Float::INFINITY
        })
        .select("users.name, sleep_records.*")
        .order("sleep_records.duration_in_minutes DESC")
    end

    private attr_reader :user
  end
end
