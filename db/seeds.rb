require_relative "../lib/seed_data"

SeedData.new.seed! if Rails.env.development?
