module V1
  class FollowBlueprint < Blueprinter::Base
    identifier :id

    field :created_at

    association :follower, blueprint: V1::UserBlueprint
    association :followee, blueprint: V1::UserBlueprint
  end
end
