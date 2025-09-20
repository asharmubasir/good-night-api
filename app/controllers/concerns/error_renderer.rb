module ErrorRenderer
  extend ActiveSupport::Concern

  private

  def render_error(error)
    error_json = {
      error: {
        code: error.code,
        message: error.message,
        detail: error.detail
      }
    }

    render json: error_json, status: error.http_status
  end
end
