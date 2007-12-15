namespace :db do
  desc "Loads a schema.rb file into the database and then loads the initial database fixtures."
  task :bootstrap => ['db:schema:load', 'db:bootstrap:load']

  namespace :bootstrap do
    desc 'Create YAML test fixtures (in db/bootstrap/*.yml) from data in an existing database. Defaults to development database. Set RAILS_ENV to override.'
    task :extract => :environment do
      sql = "SELECT * FROM %s"
      skip_tables = ["schema_info", "sessions"]
      ActiveRecord::Base.establish_connection
      tables = ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : ActiveRecord::Base.connection.tables - skip_tables
      tables.each do |table_name|
        i = "000"
        File.open("#{RAILS_ROOT}/db/bootstrap/#{table_name}.yml", 'w') do |file|
          data = ActiveRecord::Base.connection.select_all(sql % table_name)
          file.write data.inject({}) { |hash, record|
            hash["#{table_name}_#{i.succ!}"] = record
            hash
          }.to_yaml
        end
      end
    end

    desc "Load initial database fixtures (in db/bootstrap/*.yml) into the current environment's database.  Load specific fixtures using FIXTURES=x,y"
    task :load => :environment do
      require 'active_record/fixtures'

      if ENV['FIXTURES']
        fixture_files = ENV['FIXTURES'].split(/s*,s*/).map {|fixture| [File.join(RAILS_ROOT, 'db', 'bootstrap', fixture)[/(.*).(yml|csv)/i,1], fixture[/\d+_([^.]+).(yml|csv)/i, 1]]}
      else
        found_files = Dir.glob(File.join(RAILS_ROOT, 'db', 'bootstrap', '*.{yml,csv}'))
        numbered_files = found_files.select {|path| path =~ /\d+_[^.]+.(yml|csv)/i }
        fixture_files = numbered_files.sort {|x,y| x[/(\d+)_.*/,1].to_i <=> y[/(\d+)_.*/,1].to_i }.map { |fixture_path|
          [fixture_path[/(.*).(yml|csv)/i,1], fixture_path[/\d+_([^.]+).(yml|csv)/i, 1]]
        }
        fixture_files += (found_files - numbered_files).map {|file|
          path = file[0, file.rindex('.')]; [path, File.basename(path)]
        }
        raise "No fixtures found matching \"db/bootstrap/*.{yml,csv}\"! Specify fixtures using \"FIXTURES=\"" if fixture_files.empty?
      end

      ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)

      connection = ActiveRecord::Base.connection

      fixtures = fixture_files.map do |fixture_path, table_name|
        Fixtures.new(connection, table_name, nil, fixture_path)
      end
      connection.transaction(Thread.current['open_transactions'] == 0) do
        fixtures.reverse.each { |fixture| fixture.delete_existing_fixtures }
        fixtures.each { |fixture| fixture.insert_fixtures }
        # Cap primary key sequences to max(pk).
        if connection.respond_to?(:reset_pk_sequence!)
          fixture_files.each do |fixture_path, table_name|
            connection.reset_pk_sequence!(table_name)
          end
        end
      end
    end
  end
end