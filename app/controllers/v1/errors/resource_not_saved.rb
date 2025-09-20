module V1
  module Errors
    class ResourceNotSaved < ApiErrorBase
      def http_status
        :unprocessable_content
      end

      def message
        "Resource not saved"
      end
    end
  end
end
