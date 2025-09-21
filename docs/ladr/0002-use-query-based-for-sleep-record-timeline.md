# 2. Use query-based for sleep record timeline

Date: 2025-09-21

## Status

Accepted

## Context

We need a way to provide a timeline of sleep records for a user's followings.
Options considered:
- **Materialized views** - Provide fast reads, but refreshing them at scale proved too heavy and impractical. Every refresh required scanning large amounts of data, which did not finish in a reasonable time.
- **Redis fan-out** - Offers high performance but requires additional infrastructure and background jobs. Given the limited timeframe (2 days for this test project), implementing and maintaining this was not feasible.
- **On-demand query** simplest to implement, always returns fresh data, and (with proper indexes) performed surprisingly well in practice, even with large datasets generated during seeding.


## Decision

We will implement a `SleepRecords::Timeline` class that queries followings' sleep records
on demand, filtered to the last week, and ordered by `duration_in_minutes`, for simplicity, doesnt mean this doesnt work, it works quite well, with proper indexing and query.

## Consequences

- Always up-to-date results without refreshes
- Performs well in practice, even with large datasets (tested locally with 20,000 users, 1.4M follows, and ~2.5M sleep records)
  ```ruby
  rails db:seed

  # After seeding:
  User.count        # => 20_000
  Follow.count      # => 1_441_776
  SleepRecord.count # => 2_489_773
  ```

  Load testing with the provided script also confirmed good performance under concurrency:

  ```ruby
  ruby script/concurrent_api_test.rb 10 5
  # where:
  #   10 = concurrent users
  #   5  = requests per user

  OR

  ruby script/load_test.rb 1
  ```
- Simple to maintain and extend in Rails
