module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from Exception, with: :render_server_error
    rescue_from ActionController::ParameterMissing, with: :render_missing_param
    rescue_from ActiveRecord::RecordNotFound, with: :render_resource_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :render_resource_not_saved
    rescue_from JWT::DecodeError, with: :render_unauthorized
    rescue_from JWT::ExpiredSignature, with: :render_unauthorized
  end

  private

  def render_server_error(exception)
    render_error(V1::Errors::InternalServerError.new(exception.message))
  end

  def render_missing_param(exception)
    render_error(V1::Errors::BadRequest.new(exception.message))
  end

  def render_resource_not_found(exception)
    render_error(V1::Errors::ResourceNotFound.new(exception.message))
  end

  def render_resource_not_saved(exception)
    render_error(V1::Errors::ResourceNotSaved.new(exception.message))
  end

  def render_unauthorized(exception)
    render_error(V1::Errors::Unauthorized.new(exception.message))
  end
end
