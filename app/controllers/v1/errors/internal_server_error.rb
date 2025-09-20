module V1
  module Errors
    class InternalServerError < ApiErrorBase
      def http_status
        :internal_server_error
      end

      def message
        "unexpected internal error"
      end
    end
  end
end
