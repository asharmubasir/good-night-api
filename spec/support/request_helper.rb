module Requests
  module JsonHelpers
    def json
      @_json ||= JSON.parse(response.body)
    end
  end

  module HeadersHelpers
    def json_response_headers
      {
        "Content-Type" => "application/json"
      }
    end
  end
end

RSpec.configure do |config|
  config.include Requests::JsonHelpers, type: :request
  config.include Requests::HeadersHelpers
end
