# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_name  (name) UNIQUE
#
require "rails_helper"

RSpec.describe User, type: :model do
  describe "#validations" do
    it "is valid with valid attributes" do
      expect(build(:user)).to be_valid
    end

    context "when name is not present" do
      it "is invalid" do
        user = build(:user, name: nil)
        expect(user).to be_invalid
        expect(user.errors.full_messages).to include("Name can't be blank")
      end
    end

    context "when name is already taken" do
      it "is invalid" do
        create(:user, name: "John Doe")
        user = build(:user, name: "John Doe")
        expect(user).to be_invalid
        expect(user.errors.full_messages).to include("Name has already been taken")
      end
    end
  end
end
