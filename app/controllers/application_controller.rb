class ApplicationController < ActionController::API
  include ErrorRenderer
  include ExceptionHandler

  before_action :authenticate_user

  private

  def authenticate_user
    auth_header = request.headers["Authorization"]
    token = auth_header.split(" ").last if auth_header.present?
    payload = Auth::Jwt.new.decode(token)
    @current_user = User.find(payload["user_id"])
  rescue => err
    render_error(V1::Errors::Unauthorized.new(err.message))
  end

  def current_user
    @current_user
  end
end
