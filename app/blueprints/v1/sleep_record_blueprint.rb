module V1
  class SleepRecordBlueprint < Blueprinter::Base
    identifier :id

    fields :slept_at, :woke_up_at, :duration_in_minutes, :created_at

    view :timeline do
      field :user do |sleep_record, _|
        {
          id: sleep_record.user_id,
          name: sleep_record.user_name
        }
      end
    end
  end
end
