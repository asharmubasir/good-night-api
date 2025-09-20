require "rails_helper"

describe Auth::Jwt do
  subject(:jwt) { described_class.new }

  let(:payload) do
    {
      user_id: 123
    }
  end

  describe "#encode" do
    it "encodes a payload into a JWT string" do
      expect(jwt.encode(payload)).to be_a(String)
    end

    context "with invalid payload" do
      let(:payload) { "invalid" }

      it "raises an error" do
        expect { jwt.encode(payload) }.to raise_error(ArgumentError, "Payload must be a Hash")
      end
    end
  end

  describe "#decode" do
    let(:encoded_payload) { jwt.encode(payload) }

    it "returns decoded payload" do
      decoded_payload = jwt.decode(encoded_payload)
      expect(decoded_payload[:user_id]).to eq(123)
      expect(decoded_payload[:exp]).to be_present
    end

    context "with invalid token" do
      let(:encoded_payload) { "invalid" }

      it "raises an error" do
        expect { jwt.decode(encoded_payload) }.to raise_error("Token is invalid")
      end
    end

    context "with expired token" do
      let(:expires_at) { 1.day.ago - 1.second }
      let(:encoded_payload) { jwt.encode(payload, expires_at) }

      it "raises an error" do
        expect { jwt.decode(encoded_payload) }.to raise_error("Token has expired")
      end
    end
  end
end
