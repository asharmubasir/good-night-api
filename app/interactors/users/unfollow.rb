module Users
  class Unfollow < ApplicationAction
    delegate :user, :followee, to: :context, private: true

    validates :user, :followee, presence: true
    validate :prevent_self_unfollow, if: -> { user.present? && followee.present? }
    validate :user_must_be_following_to_unfollow, if: -> { user.present? && followee.present? }

    def call
      validate_params!

      Follow.find_by(follower: user, followee: followee).destroy!
    rescue ActiveRecord::RecordNotDestroyed
      context.fail!(error: [ I18n.t("errors.record_not_destroyed") ])
    end

    private

    def prevent_self_unfollow
      errors.add(:base, I18n.t("errors.cannot_follow_or_unfollow_themselves")) if user.id == followee.id
    end

    def user_must_be_following_to_unfollow
      errors.add(:base, I18n.t("errors.not_following")) unless user.followings.exists?(id: followee.id)
    end
  end
end
