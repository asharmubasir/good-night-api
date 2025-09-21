#!/usr/bin/env ruby

require 'net/http'
require 'json'

class ConcurrentApiTest
  def initialize(base_url: 'http://localhost:3000')
    @base_url = base_url
    @results = []
    @errors = []
  end

  def test_concurrent(concurrent_users: 10, requests_per_user: 5)
    puts "🔥 Concurrent API Test"
    puts "====================="
    puts "Target: #{@base_url}/v1/sleep_timelines"
    puts "Concurrent users: #{concurrent_users}"
    puts "Requests per user: #{requests_per_user}"
    puts "Total requests: #{concurrent_users * requests_per_user}"
    puts

    # Get JWT tokens for different users
    jwt_tokens = get_multiple_jwt_tokens(concurrent_users)

    if jwt_tokens.empty?
      puts "❌ Could not get any JWT tokens. Test aborted."
      return
    end

    puts "✅ Got #{jwt_tokens.length} JWT tokens"
    puts

    # Start concurrent test
    puts "🚀 Starting concurrent requests..."
    start_time = Time.now

    threads = (1..concurrent_users).map do |thread_id|
      Thread.new do
        token = jwt_tokens.sample # Random token for this thread
        thread_results = []

        requests_per_user.times do |request_num|
          begin
            request_start = Time.now
            response = make_timeline_request(token)
            request_end = Time.now

            result = {
              thread_id: thread_id,
              request_num: request_num,
              status: response[:status],
              response_time: request_end - request_start,
              body_size: response[:body].length,
              records_count: parse_records_count(response[:body])
            }

            thread_results << result
            print "." # Progress indicator

          rescue => e
            @errors << {
              thread_id: thread_id,
              request_num: request_num,
              error: e.message
            }
            print "E"
          end
        end

        thread_results
      end
    end

    # Wait for all threads to complete
    all_results = threads.map(&:value).flatten
    @results = all_results.compact

    total_time = Time.now - start_time

    puts "\n\n📊 Concurrent Test Results:"
    analyze_results(total_time)
  end

  private

  def get_multiple_jwt_tokens(count)
    puts "🔑 Getting JWT tokens for #{count} users..."

    begin
      require_relative '../config/environment'

      # Get random users for testing
      users = User.limit(count).offset(rand(User.count - count)).to_a

      tokens = users.map do |user|
        token = create_jwt_token_for_user(user)
        print "."
        token
      end.compact

      puts " Done!"
      tokens

    rescue => e
      puts "❌ Could not get users from database: #{e.message}"
      puts "Falling back to single token approach..."

      # Fallback: get one token and reuse it
      token = get_single_jwt_token
      token ? [ token ] * count : []
    end
  end

  def create_jwt_token_for_user(user)
    # Direct token creation (faster than HTTP requests)
    begin
      require_relative '../app/lib/auth/jwt'
      Auth::Jwt.new.encode(user_id: user.id)
    rescue => e
      puts "⚠️  Could not create JWT directly: #{e.message}"
      nil
    end
  end

  def get_single_jwt_token
    # HTTP-based token getting (same as Step 1)
    uri = URI("#{@base_url}/v1/sessions")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'

    begin
      require_relative '../config/environment'
      first_user_name = User.first&.name || "John Doe"
    rescue
      first_user_name = "John Doe"
    end

    request.body = { name: first_user_name }.to_json

    begin
      response = http.request(request)

      if response.code.to_i == 200 || response.code.to_i == 201
        parsed = JSON.parse(response.body)
        return parsed['token'] || parsed['jwt'] || parsed['access_token']
      end
    rescue => e
      puts "❌ Could not get JWT token: #{e.message}"
    end

    nil
  end

  def make_timeline_request(jwt_token)
    uri = URI("#{@base_url}/v1/sleep_timelines")

    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 30

    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{jwt_token}"
    request['Content-Type'] = 'application/json'

    response = http.request(request)

    {
      status: response.code.to_i,
      body: response.body,
      headers: response.to_hash
    }
  rescue => e
    {
      status: 0,
      body: "Error: #{e.message}",
      headers: {}
    }
  end

  def parse_records_count(body)
    begin
      parsed = JSON.parse(body)
      parsed.dig('sleep_timeline')&.length || 0
    rescue
      0
    end
  end

  def analyze_results(total_time)
    return if @results.empty?

    successful_requests = @results.select { |r| r[:status] == 200 }
    failed_requests = @results.select { |r| r[:status] != 200 }

    response_times = successful_requests.map { |r| r[:response_time] }

    puts "━" * 60
    puts "⏱️  PERFORMANCE METRICS:"
    puts "   Total time: #{total_time.round(2)}s"
    puts "   Total requests: #{@results.count}"
    puts "   Successful requests: #{successful_requests.count}"
    puts "   Failed requests: #{failed_requests.count + @errors.count}"
    puts "   Success rate: #{(successful_requests.count.to_f / @results.count * 100).round(1)}%"
    puts "   Requests per second: #{(@results.count / total_time).round(1)}"

    if response_times.any?
      puts "\n📈 RESPONSE TIME ANALYSIS:"
      puts "   Average: #{(response_times.sum / response_times.count * 1000).round(1)}ms"
      puts "   Fastest: #{(response_times.min * 1000).round(1)}ms"
      puts "   Slowest: #{(response_times.max * 1000).round(1)}ms"
      puts "   95th percentile: #{(percentile(response_times, 95) * 1000).round(1)}ms"
    end

    if successful_requests.any?
      puts "\n📊 DATA ANALYSIS:"
      total_records = successful_requests.sum { |r| r[:records_count] }
      avg_records = total_records.to_f / successful_requests.count
      puts "   Total records returned: #{total_records}"
      puts "   Average records per request: #{avg_records.round(1)}"
    end

    if failed_requests.any?
      puts "\n❌ FAILURE BREAKDOWN:"
      failed_requests.group_by { |r| r[:status] }.each do |status, requests|
        puts "   HTTP #{status}: #{requests.count} requests"
      end
    end

    if @errors.any?
      puts "\n🚨 ERROR SUMMARY:"
      @errors.group_by { |e| e[:error] }.each do |error, occurrences|
        puts "   #{error}: #{occurrences.count} times"
      end
    end

    puts "\n🏆 PERFORMANCE VERDICT:"
    if response_times.empty?
      puts "   🔴 NO SUCCESSFUL REQUESTS"
    elsif response_times.max < 0.1
      puts "   🟢 EXCELLENT - All requests under 100ms"
    elsif percentile(response_times, 95) < 0.2
      puts "   🟡 GOOD - 95% of requests under 200ms"
    elsif percentile(response_times, 95) < 0.7
      puts "   🟠 ACCEPTABLE - 95% of requests under 700ms"
    else
      puts "   🔴 NEEDS OPTIMIZATION - Too many slow requests"
    end
  end

  def percentile(array, percentile)
    sorted = array.sort
    index = (percentile / 100.0 * (sorted.length - 1)).round
    sorted[index]
  end
end

if __FILE__ == $0
  puts "Make sure your Rails server is running: rails server"
  puts

  # Parse command line arguments or use defaults
  concurrent_users = ARGV[0]&.to_i || 5
  requests_per_user = ARGV[1]&.to_i || 3

  test = ConcurrentApiTest.new
  test.test_concurrent(
    concurrent_users: concurrent_users,
    requests_per_user: requests_per_user
  )

  puts "\n💡 To increase load:"
  puts "   ruby script/concurrent_api_test.rb 10 5    # 10 users, 5 requests each"
  puts "   ruby script/concurrent_api_test.rb 20 10   # 20 users, 10 requests each"
end
