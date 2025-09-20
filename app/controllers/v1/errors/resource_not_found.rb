module V1
  module Errors
    class ResourceNotFound < ApiErrorBase
      def http_status
        :not_found
      end

      def message
        "Resource not found"
      end
    end
  end
end
