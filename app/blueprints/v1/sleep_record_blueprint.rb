module V1
  class SleepRecordBlueprint < Blueprinter::Base
    identifier :id

    fields :slept_at, :woke_up_at, :duration_in_minutes, :created_at
  end
end
