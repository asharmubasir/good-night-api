module Auth
  class Jwt
    ALGORITHM = "HS256".freeze

    def initialize(token = ENV["SECRET_KEY_BASE"])
      @token = token
    end

    def encode(payload, expires_at = 24.hours.from_now)
      raise ArgumentError, "Payload must be a Hash" unless payload.is_a?(Hash)

      payload[:exp] = expires_at.to_i
      JWT.encode(payload, @token, ALGORITHM)
    end

    def decode(payload)
      JWT.decode(payload, @token, ALGORITHM)[0].with_indifferent_access
    rescue JWT::ExpiredSignature
      raise "Token has expired"
    rescue JWT::DecodeError
      raise "Token is invalid"
    end
  end
end
