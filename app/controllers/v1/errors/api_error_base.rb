module V1
  module Errors
    class ApiErrorBase < StandardError
      attr_reader :detail

      def initialize(detail = nil)
        @detail = Array.wrap(detail)
      end

      def code
        @code ||= self.class.name.demodulize.underscore
      end

      def message
        "API Error"
      end

      def http_status
        :internal_server_error
      end
    end
  end
end
