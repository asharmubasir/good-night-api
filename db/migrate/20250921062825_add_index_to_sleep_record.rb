class AddIndexToSleepRecord < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    add_index :sleep_records,
      [ :user_id, :slept_at, :duration_in_minutes ],
      order: { duration_in_minutes: :desc },
      where: "duration_in_minutes IS NOT NULL",
      name: 'idx_sleep_records_timeline_optimized'
  end

  def down
    remove_index :sleep_records, name: "idx_sleep_records_timeline_optimized"
  end
end
