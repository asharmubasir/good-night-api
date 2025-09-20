FactoryBot.define do
  factory :sleep_record do
    user { nil }
    slept_at { "2025-09-20 10:01:45" }
    woke_up_at { "2025-09-20 10:01:45" }
    duration_in_minutes { 1 }
  end
end
