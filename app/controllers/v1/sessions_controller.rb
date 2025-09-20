class V1::SessionsController < ApplicationController
  skip_before_action :authenticate_user, only: [ :create ]

  def create
    user = User.find_by(name: name_params)

    if user.present?
      payload = { user_id: user.id }
      token = Auth::Jwt.new.encode(payload)

      render json: { token: token }
    else
      render_error(V1::Errors::BadRequest.new(I18n.t("errors.user_not_found")))
    end
  end

  private

  def name_params
    params.require(:name)
  end
end
