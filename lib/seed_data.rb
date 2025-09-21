require "factory_bot"

class SeedData
  include FactoryBot::Syntax::Methods

  def initialize
    @users = []
    @superstars = []
    @regular_users = []
  end

  def seed!
    puts "🌱 Starting database seeding..."

    # Clear existing data (optional - comment out if you want to keep existing data)
    clear_existing_data if Rails.env.development?

    create_users
    create_follow_relationships
    create_sleep_records

    puts "✅ Database seeding completed!"
    print_statistics
  end

  private

  def clear_existing_data
    puts "🧹 Clearing existing data..."
    Follow.delete_all
    SleepRecord.delete_all
    User.delete_all

    # Reset primary key sequences
    ActiveRecord::Base.connection.reset_pk_sequence!("users")
    ActiveRecord::Base.connection.reset_pk_sequence!("sleep_records")
    ActiveRecord::Base.connection.reset_pk_sequence!("follows")
  end

  def create_users
    puts "👥 Creating 20,000 users..."

    user_names = generate_unique_names(20_000)

    # Batch insert users for better performance
    users_data = user_names.map.with_index do |name, index|
      {
        name: name,
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    # Insert in batches to avoid memory issues
    users_data.each_slice(2000) do |batch|
      User.insert_all(batch)
    end

    # Load users back from database
    @users = User.all.to_a

    # Select superstars (5% = 1,000 users)
    @superstars = @users.sample(1_000)
    @regular_users = @users - @superstars

    puts "   ⭐ #{@superstars.count} superstars selected"
    puts "   👤 #{@regular_users.count} regular users"
  end

  def create_follow_relationships
    puts "🔗 Creating follow relationships..."

    follow_data = []

    # Each superstar gets 300-500 followers (reasonable for 20K users)
    @superstars.each_with_index do |superstar, index|
      puts "   Creating followers for superstar #{index + 1}/#{@superstars.count}" if (index + 1) % 100 == 0

      # Select 300-500 random users to follow this superstar (excluding the superstar themselves)
      potential_followers = @users - [ superstar ]
      follower_count = rand(300..500).clamp(0, potential_followers.count)
      followers = potential_followers.sample(follower_count)

      followers.each do |follower|
        follow_data << {
          follower_id: follower.id,
          followee_id: superstar.id,
          created_at: random_past_date(90.days),
          updated_at: Time.current
        }
      end
    end

    # Regular users follow each other randomly (smaller numbers)
    @regular_users.each_with_index do |user, index|
      puts "   Creating follows for regular user #{index + 1}/#{@regular_users.count}" if (index + 1) % 2000 == 0

      # Each regular user follows 10-100 other users randomly
      follow_count = rand(10..100)
      potential_followees = @users - [ user ] # Don't follow themselves
      followees = potential_followees.sample(follow_count)

      followees.each do |followee|
        follow_data << {
          follower_id: user.id,
          followee_id: followee.id,
          created_at: random_past_date(180.days),
          updated_at: Time.current
        }
      end
    end

    # Remove duplicates (in case of random collisions)
    follow_data = follow_data.uniq { |f| [ f[:follower_id], f[:followee_id] ] }

    puts "   💾 Inserting #{follow_data.count} follow relationships..."

    # Insert in batches
    follow_data.each_slice(10000) do |batch|
      Follow.insert_all(batch)
    end
  end

  def create_sleep_records
    puts "😴 Creating sleep records (minimum 100 per user)..."

    @users.each_with_index do |user, index|
      puts "   Creating sleep records for user #{index + 1}/#{@users.count}" if (index + 1) % 1000 == 0

      sleep_records_data = generate_realistic_sleep_records(user.id, 100 + rand(50))

      # Skip if no valid records were generated
      next if sleep_records_data.empty?

      # Insert in batches with error handling
      sleep_records_data.each_slice(100) do |batch|
        begin
          SleepRecord.insert_all(batch)
        rescue => e
          puts "   ⚠️  Error inserting sleep records for user #{user.id}: #{e.message}"
          puts "   Sample record: #{batch.first.inspect}" if batch.any?
        end
      end
    end
  end

  def generate_realistic_sleep_records(user_id, count)
    records = []
    start_date = 6.months.ago.to_date
    end_date = Date.current

    count.times do |i|
      # Distribute sleep records evenly over the past 6 months
      progress = i.to_f / count
      target_date = start_date + (progress * (end_date - start_date)).days

      # Realistic bedtime between 21:00 and 02:00
      bedtime_hour = [ 21, 22, 23, 0, 1, 2 ].sample
      bedtime_minute = rand(0..59)

      # Create the sleep timestamp
      if bedtime_hour >= 21 # 9pm, 10pm, 11pm - same day
        slept_at = target_date.to_time + bedtime_hour.hours + bedtime_minute.minutes
      else # midnight, 1am, 2am - next day
        slept_at = (target_date + 1.day).to_time + bedtime_hour.hours + bedtime_minute.minutes
      end

      # Realistic sleep duration: 4-12 hours, with most people sleeping 6-9 hours
      sleep_duration_minutes = case rand(100)
      when 0..5     # 5% - very short sleep (4-5 hours)
        rand(240..300)
      when 6..15    # 10% - short sleep (5-6 hours)
        rand(300..360)
      when 16..70   # 55% - normal sleep (6-8 hours)
        rand(360..480)
      when 71..90   # 20% - long sleep (8-9 hours)
        rand(480..540)
      else          # 10% - very long sleep (9-12 hours)
        rand(540..720)
      end

      woke_up_at = slept_at + sleep_duration_minutes.minutes

      # Ensure timestamps are within valid range (PostgreSQL supports 4713 BC to 294276 AD)
      min_time = Time.new(1970, 1, 1) # Use Unix epoch as safe minimum
      max_time = Time.current + 1.day  # Don't go beyond tomorrow

      if slept_at < min_time || slept_at > max_time || woke_up_at < min_time || woke_up_at > max_time
        puts "   ⚠️  Invalid timestamp generated: slept_at=#{slept_at}, woke_up_at=#{woke_up_at}" if records.empty?
        next
      end

      records << {
        user_id: user_id,
        slept_at: slept_at,
        woke_up_at: woke_up_at,
        duration_in_minutes: sleep_duration_minutes,
        created_at: woke_up_at,
        updated_at: woke_up_at
      }
    end

    records
  end

  def generate_unique_names(count)
    first_names = %w[
      James Mary John Patricia Robert Jennifer Michael Linda William Elizabeth
      David Barbara Richard Susan Joseph Jessica Thomas Sarah Christopher Karen
      Charles Nancy Daniel Lisa Matthew Betty Donald Helen Anthony Sharon
      Mark Donna Paul Carol Steven Ruth Kenneth Maria Joshua Margaret
      Kevin Sandra Andrew Kimberly Scott Donna Edward Betty Raymond Helen
      Gregory Sharon Joshua Deborah Christopher Amy Patrick Angela Jack Martha
      Dennis Julie Jerry Heather Tyler Julie Aaron Virginia Henry Carolyn
      Zachary Martha Ralph Marie Carl Margaret Arthur Sharon Adam Elizabeth
      Nathan Sharon Peter Julie Noah Michelle Benjamin Christina Samuel Ashley
      Frank Stephanie Gregory Helen Raymond Martha Jack Ruth Dennis Deborah
      Jerry Joyce Tyler Christina Eugene Shirley Harold Angela Arthur Virginia
      Roger Amy Lawrence Janet Wayne Kathryn Albert Janice Harold Ruth
    ]

    last_names = %w[
      Smith Johnson Williams Brown Jones Garcia Miller Davis Rodriguez Martinez
      Hernandez Lopez Gonzalez Wilson Anderson Thomas Taylor Moore Jackson Martin
      Lee Perez Thompson White Harris Sanchez Clark Ramirez Lewis Robinson Walker
      Young Allen King Wright Lopez Hill Scott Green Adams Baker Gonzalez Nelson
      Carter Mitchell Perez Roberts Turner Phillips Campbell Parker Evans Edwards
      Collins Stewart Sanchez Morris Rogers Reed Cook Morgan Bell Murphy Bailey
      Rivera Cooper Richardson Cox Howard Ward Torres Peterson Gray Ramirez James
      Watson Brooks Kelly Sanders Price Bennett Wood Barnes Ross Henderson
      Coleman Jenkins Perry Powell Long Patterson Hughes Flores Washington Butler
      Simmons Foster Gonzales Bryant Alexander Russell Griffin Diaz Hayes Myers
    ]

    names = []
    used_names = Set.new

    while names.length < count
      first_name = first_names.sample
      last_name = last_names.sample
      full_name = "#{first_name} #{last_name}"

      # Add random number if name already exists to ensure uniqueness for large datasets
      if used_names.include?(full_name)
        counter = 1
        loop do
          numbered_name = "#{full_name} #{counter}"
          unless used_names.include?(numbered_name)
            full_name = numbered_name
            break
          end
          counter += 1
        end
      end

      names << full_name
      used_names << full_name
    end

    names
  end

  def random_past_date(max_days_ago)
    # Convert duration to days safely
    days = case max_days_ago
    when ActiveSupport::Duration
      max_days_ago.in_days.to_i
    when Integer
      max_days_ago
    else
      max_days_ago.to_i
    end

    # Generate random timestamp within the range
    random_days = rand(0..days)
    random_hours = rand(0..23)
    random_minutes = rand(0..59)

    random_days.days.ago + random_hours.hours + random_minutes.minutes
  end

  def print_statistics
    puts "\n📊 Database Statistics:"
    puts "   Users: #{User.count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "   Follows: #{Follow.count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "   Sleep Records: #{SleepRecord.count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "   Top followed users: #{Follow.group(:followee_id).count.values.max(5).join(', ')}"
    puts "   Average sleep duration: #{(SleepRecord.average(:duration_in_minutes) || 0).round(1)} minutes"
  end
end
