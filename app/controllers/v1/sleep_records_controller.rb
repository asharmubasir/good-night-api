module V1
  class SleepRecordsController < ApplicationController
    def clock_in
      result = SleepRecords::ClockIn.call(user: current_user, clock_time: Time.current)

      if result.success?
        render json: SleepRecordBlueprint.render(result.sleep_record, root: :sleep_record), status: :created
      else
        render_error(Errors::BadRequest.new(result.error))
      end
    end
  end
end
