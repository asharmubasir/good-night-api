require_relative "../lib/seed_data"

DatabaseSeed.new.seed! if Rails.env.development?
