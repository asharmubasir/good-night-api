class ApplicationAction
  include Interactor
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  private

  def validate_params!
    context.fail!(error: errors.full_messages, message: errors.full_messages) if invalid?
  end
end
