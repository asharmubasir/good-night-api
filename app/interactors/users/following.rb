module Users
  class Following < ApplicationAction
    delegate :user, :followee, to: :context, private: true

    validates :user, :followee, presence: true
    validate :prevent_duplicate_follow, if: -> { user.present? && followee.present? }
    validate :prevent_self_follow, if: -> { user.present? && followee.present? }

    def call
      validate_params!

      context.follow = Follow.create!(follower: user, followee:)
    rescue ActiveRecord::RecordInvalid => e
      context.fail!(error: [ e.message ])
    end

    private

    def prevent_duplicate_follow
      errors.add(:base, I18n.t("errors.already_followed")) if user.followings.exists?(id: followee.id)
    end

    def prevent_self_follow
      errors.add(:base, I18n.t("errors.cannot_follow_themselves")) if user.id == followee.id
    end
  end
end
