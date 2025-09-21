class RemoveUnusedIndexOnSleepRecord < ActiveRecord::Migration[8.0]
  def change
    remove_index :sleep_records, name: "index_sleep_records_on_duration_in_minutes_desc"
  end
end
