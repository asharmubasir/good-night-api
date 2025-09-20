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
class User < ApplicationRecord
  has_many :sleep_records, dependent: :destroy
  has_one :active_sleep_record, -> { active }, class_name: "SleepRecord"

  # User is following other users
  has_many :following_relationships, class_name: "Follow", foreign_key: :follower_id
  has_many :followings, through: :following_relationships, source: :followee

  # User is followed by other users
  has_many :follower_relationships, class_name: "Follow", foreign_key: :followee_id
  has_many :followers, through: :follower_relationships, source: :follower

  validates :name, presence: true, uniqueness: true
end
