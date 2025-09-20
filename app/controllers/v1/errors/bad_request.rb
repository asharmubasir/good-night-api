module V1
  module Errors
    class BadRequest < ApiErrorBase
      def http_status
        :bad_request
      end

      def message
        "the request body is malformed or not valid"
      end
    end
  end
end
