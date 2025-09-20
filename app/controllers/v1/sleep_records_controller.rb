module V1
  class SleepRecordsController < ApplicationController
    include Pagy::Backend

    def index
      collection = current_user.sleep_records.order(created_at: :desc)
      pagy, records = pagy_countless(collection)
      meta = { pagination: pagy_metadata(pagy) }

      render json: V1::SleepRecordBlueprint.render(records, root: :sleep_records, meta:),
        status: :ok
    end

    def clock_in
      result = SleepRecords::ClockIn.call(user: current_user, clock_time: Time.current)

      if result.success?
        render json: SleepRecordBlueprint.render(result.sleep_record, root: :sleep_record), status: :created
      else
        render_failure(result.error)
      end
    end

    def clock_out
      result = SleepRecords::ClockOut.call(user: current_user, clock_time: Time.current)

      if result.success?
        render json: SleepRecordBlueprint.render(result.sleep_record, root: :sleep_record), status: :ok
      else
        render_failure(result.error)
      end
    end
  end
end
