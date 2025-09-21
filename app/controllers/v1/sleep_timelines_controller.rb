module V1
  class SleepTimelinesController < ApplicationController
    def index
      timeline_items = SleepRecords::Timeline.new(current_user).call

      pagy, records = pagy_countless(timeline_items)
      meta = { pagination: pagy_metadata(pagy) }

      render json: V1::SleepRecordBlueprint.render(records, root: :sleep_timeline, meta:), status: :ok
    end
  end
end
