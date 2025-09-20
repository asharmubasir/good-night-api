module V1
  class ApiErrorBlueprint < ::Blueprinter::Base
    fields :code, :message
    field :detail, unless: ->(_field_name, error, options) { error.detail.nil? }
  end
end
