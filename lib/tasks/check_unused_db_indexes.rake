namespace :db do
  desc "Check unused indexes in the development database"
  task unused_indexes: :environment do
    unused_indexes = ActiveRecord::Base.connection.execute(<<-SQL)
      SELECT
          i.indexrelname as index_name,
          i.relname as table_name,
          i.idx_scan,
          pg_size_pretty(pg_relation_size(i.indexrelid)) as size
      FROM pg_stat_user_indexes i
      WHERE i.idx_scan = 0
      ORDER BY pg_relation_size(i.indexrelid) DESC;
    SQL

    puts "Unused Indexes in #{Rails.env}:"
    puts "=" * 50

    if unused_indexes.any?
      unused_indexes.each do |row|
        puts "#{row['index_name']} on #{row['table_name']}: #{row['size']}"
      end
    else
      puts "No unused indexes found!"
    end
  end
end
