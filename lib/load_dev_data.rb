# this file is for manually loading all the /db/migrate/dev_data into any environment
# used specifically for loading into a test "production" environment (ie. dreamhost or textdrive sandbox)
# to run simply type `ruby lib/load_dev_data.rb` from the command line

require File.dirname(__FILE__) + '/../config/environment'
if RAILS_ENV == 'production'
  require 'active_support/inflector'
  require 'active_record'
  require 'active_record/fixtures'

  fixtures_dir = File.expand_path "#{RAILS_ROOT}/db/migrate/dev_data"

  tables = []
  classes = []
  Dir["#{fixtures_dir}/**"].map do |file|
    table = File.basename(file, ".yml") if File.extname(file) == ".yml"
    if table
      tables << table
      classes << Inflector::classify(table)
    end
  end
  
  Fixtures::create_fixtures(fixtures_dir, tables)
end
