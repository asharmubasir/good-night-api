class AddIndexUserToSleepRecords < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    # Partial index to quickly check if a user has an active sleep record.
    # Supports queries using the SleepRecord.active scope:
    #   user.sleep_records.active.any?

    add_index :sleep_records, [ :user_id, :woke_up_at ],
      where: "woke_up_at IS NULL",
      algorithm: :concurrently,
      name: "index_active_sleep_records_on_user_and_woke_up_at"
  end
end
