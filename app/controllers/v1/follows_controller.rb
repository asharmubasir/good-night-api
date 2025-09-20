module V1
  class FollowsController < ApplicationController
    before_action :set_followee, only: :create

    def create
      result = Users::Following.call(user: current_user, followee: @followee)

      if result.success?
        render json: V1::FollowBlueprint.render(result.follow, root: :follow), status: :created
      else
        render_failure(result.error)
      end
    end

    private

    def set_followee
      @followee = User.find(followee_params)
    end

    def followee_params
      params.require(:followee_id)
    end
  end
end
