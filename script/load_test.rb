#!/usr/bin/env ruby

require_relative "concurrent_api_test"

class LoadTest < ConcurrentApiTest
  def test_production_like_load
    puts "🌍 Realistic Production-Like Load Test"
    puts "======================================"
    puts

    # Test scenarios that mimic real usage
    scenarios = [
      { name: "Light Load", users: 5, requests: 5, description: "Normal usage" },
      { name: "Medium Load", users: 15, requests: 10, description: "Busy period" },
      { name: "Heavy Load", users: 30, requests: 15, description: "Peak traffic" },
      { name: "Burst Load", users: 50, requests: 5, description: "Sudden spike" }
    ]

    scenarios.each_with_index do |scenario, index|
      puts "#{index + 1}. 🧪 Testing: #{scenario[:name]} (#{scenario[:description]})"
      puts "   #{scenario[:users]} concurrent users, #{scenario[:requests]} requests each"
      puts

      test_concurrent(
        concurrent_users: scenario[:users],
        requests_per_user: scenario[:requests]
      )

      puts "\n" + "=" * 60 + "\n"

      # Brief pause between scenarios to let server recover
      sleep 2 if index < scenarios.length - 1
    end

    puts "📊 SUMMARY:"
    puts "This test simulates different load patterns your API might face"
    puts "in production. It helps identify at what point performance degrades."
  end

  def test_connection_pool_exhaustion
    puts "🔗 Connection Pool Exhaustion Test"
    puts "=================================="
    puts

    # Rails default connection pool is usually 5
    # Let's test with more concurrent connections than the pool size
    pool_size = get_connection_pool_size
    puts "Current database connection pool size: #{pool_size}"

    test_concurrent(
      concurrent_users: pool_size + 5,  # More than pool size
      requests_per_user: 3
    )

    puts "\n📋 Analysis:"
    puts "If you see failures or very slow queries, you might need to:"
    puts "1. Increase database pool size in config/database.yml"
    puts "2. Add connection pooling middleware"
    puts "3. Optimize slow queries"
  end

  def test_sustained_load
    puts "⏱️  Sustained Load Test (60 seconds)"
    puts "==================================="
    puts "This test runs continuous load for 1 minute to check for:"
    puts "- Memory leaks"
    puts "- Connection leaks"
    puts "- Performance degradation over time"
    puts

    start_time = Time.now
    total_requests = 0

    while Time.now - start_time < 60 # Run for 60 seconds
      puts "⏳ Running sustained load... #{(Time.now - start_time).round}s"

      result = test_concurrent(
        concurrent_users: 10,
        requests_per_user: 5
      )

      total_requests += 50
      sleep 1 # Brief pause between waves
    end

    elapsed = Time.now - start_time
    puts "\n📊 Sustained Load Results:"
    puts "   Duration: #{elapsed.round(1)} seconds"
    puts "   Total requests: #{total_requests}"
    puts "   Average requests/second: #{(total_requests / elapsed).round(1)}"
  end

  private

  def get_connection_pool_size
    begin
      require_relative '../config/environment'
      ActiveRecord::Base.connection_pool.size
    rescue
      5 # Default assumption
    end
  end
end

if __FILE__ == $0
  puts "🚀 Choose a test type:"
  puts "1. Production-like scenarios"
  puts "2. Connection pool exhaustion"
  puts "3. Sustained load test"
  puts

  choice = ARGV[0] || "1"

  test = LoadTest.new

  case choice
  when "1"
    test.test_production_like_load
  when "2"
    test.test_connection_pool_exhaustion
  when "3"
    test.test_sustained_load
  else
    puts "Invalid choice. Running production-like scenarios..."
    test.test_production_like_load
  end

  puts "\n💡 To run different tests:"
  puts "   ruby script/realistic_load_test.rb 1    # Production scenarios"
  puts "   ruby script/realistic_load_test.rb 2    # Connection pool test"
  puts "   ruby script/realistic_load_test.rb 3    # Sustained load"
end
