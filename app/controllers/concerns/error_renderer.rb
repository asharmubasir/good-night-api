module ErrorRenderer
  extend ActiveSupport::Concern

  private

  def render_failure(error)
    render json: V1::ApiErrorBlueprint.render(V1::Errors::ResourceNotSaved.new(error), root: :error),
      status: :unprocessable_content
  end

  def render_error(error)
    render json: V1::ApiErrorBlueprint.render(error, root: :error), status: error.http_status
  end
end
