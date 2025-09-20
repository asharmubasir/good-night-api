Blueprinter.configure do |config|
  config.generator = Oj # default is JSON
  config.sort_fields_by = :definition
  config.datetime_format = ->(datetime) { datetime.nil? ? datetime : datetime.utc.iso8601 }
end

Oj::Rails.mimic_JSON
