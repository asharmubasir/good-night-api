require_relative "../lib/seed_data"

DatabaseSeeder.new.seed! if Rails.env.development?
