class CreateSleepRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :sleep_records do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :slept_at
      t.datetime :woke_up_at
      t.integer :duration_in_minutes

      t.timestamps
    end

    add_index :sleep_records, :duration_in_minutes,
      order: { duration_in_minutes: :desc },
      where: "duration_in_minutes IS NOT NULL",
      name: "index_sleep_records_on_duration_in_minutes_desc"
  end
end
