module V1
  module Errors
    class Unauthorized < ApiErrorBase
      def http_status
        :unauthorized
      end

      def message
        "Unauthorized request"
      end
    end
  end
end
