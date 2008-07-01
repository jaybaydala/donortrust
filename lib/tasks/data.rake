# A generic database dumper to help migrating data between Rails migrations.
# The advantage over mysqldump is that it's much easier to transform CSVs
# into the desired format with a script.
#
# Currently only dumping/loading to/from CSV is supported. But it's possible
# to extend DBDumper to support other data formats.
#
# The CSV dumper/loader smoothes over differences between migrations, by
# 1) ignore tables that no longer exist
# 2) ignore fields that no longer exist
# 3) use default value for new fields
#
# This script depends on 'mysql' gem
#
# rake db:csv:dump # dump to a new directory under $RAILS_ROOT/tmp/db-dump/csv
# rake db:csv:load # load to csv from the newest directory under $RAILS_ROOT/tmp/db-dump/csv
# rake db:csv:dump ENV=$SOME_PATH # dump to some path
# rake db:csv:load ENV=$SOME_PATH # load from some path
#


ENV['RAILS_ENV'] = "development" unless ENV['RAILS_ENV']
require 'fileutils'
require 'yaml'
require 'erb'
require 'mysql'
require 'faster_csv'

class DBDumper

  DUMP_DIR_ROOT = "#{RAILS_ROOT}/tmp/db-dump/"

  class << self
    def dump(dir=nil)
      # "make_dump_dir" should be a class method, but I can't figure out how to
      # make "format" an abstract method.
      # The problem is that reference to abstract class method is resolved at compile
      # time, so actual implementation is never seen.
      if dir
        self.new(dir).dump
      else
        self.new.use_new_dump_dir.dump
      end
    end

    def load(dir=nil)
      # ditto as previous comment
      if dir
        self.new(dir).load
      else
        self.new.use_last_dump_dir.load
      end
    end
  end

  public

  def initialize(dir=nil)
    ## @dir is the directory to load from or dump to.
    @dir = dir
  end

  attr_accessor :dir


  def dump
    ## dump the current db snapshot
    ## data + schema
    raise "abstract method"
  end

  def load
    ## load a db snapshot
    raise "abstract method"
  end

  def use_new_dump_dir
    @dir=make_dump_dir
    self
  end

  def make_dump_dir
    ## create a timestampped directory to dump file in
    dir = dump_dir_root + "/#{Time.now.strftime('%Y%m%d-%H%M%S')}"
    FileUtils.mkdir_p dir
    dir
  end

  def use_last_dump_dir
    @dir=last_dump_dir
    self
  end

  def last_dump_dir
    ## this is the last timestammped directory
    dirs=Dir[dump_dir_root+"/*"].sort
    if dirs.empty?
      raise "No dump directory yet."
    else
      dirs.last
    end
  end

  def format
    raise "abstract method"
  end

  def dump_dir_root
    File.expand_path(DUMP_DIR_ROOT+"/"+format)
  end

end


module MySQLConnection
  @@connection = nil
  def connection
    # returns a mysql connection
    unless @@connection
      # read from yaml
      cfg=YAML::load_file("#{RAILS_ROOT}/config/database.yml")[ENV['RAILS_ENV']]
      # connect by socket or port
      raise "Only MySQL is supported." unless cfg["adapter"] == "mysql"
      args={}
      if cfg.has_key? "host"
        args[:host] = cfg["host"]
        args[:port] = cfg["port"]
      elsif cfg.has_key? "socket"
        args[:sock] = cfg["socket"]
        args[:host] = nil
        args[:port] = nil
      else
        raise "Unknown connection method"
      end

      #host=nil, user=nil, passwd=nil, db=nil, port=nil, sock=nil, flag=nil
      @@connection=Mysql::connect(*[args[:host],
                                    cfg["username"],
                                    cfg["password"],
                                    cfg["database"],
                                    args[:port],
                                    args[:sock],
                                    nil
                                   ])
    end
    @@connection
  end
end


class CSVDumper < DBDumper
  include MySQLConnection
  # schema ==> schema.rb
  # data   ==> <table>.csv
  def initialize(*args)
    super *args
  end

  def format
    "csv"
  end

  public

  def dump
    dump_csv
    #dump_schema
  end

  def load
    #load_schema
    load_csv
  end

  def dump_schema
    puts "=============================="
    puts "* Dumping Schema to #{dir}"
    puts "=============================="

    ENV["SCHEMA"] = dir + "/schema.rb"
    Rake::Task["db:schema:dump"].invoke
  end

  def dump_csv
    tables = connection.list_tables - ['sessions','schema_info']
    tables.each do |table|
      file = "#{dir}/#{table}.csv"
      puts "=============================="
      puts "** Dumping #{table} to #{file}"
      puts "=============================="

      FasterCSV.open(file,"w") do |csv|
        connection.query("select * from #{table}") do |res|
          fields=res.fetch_fields
          csv << fields.map { |f| f.name }
          res.each do |row|
            csv << row
          end
        end
      end

    end
  end

  # Take care to handle schema change,
  # -if a field is in current schema and csv , use it.
  # -if a field is in current schema but not csv, use default
  # -if a field is not in current schema but in csv, ignore
  #
  # It should be straightforward to munge through the CSV
  # to handle special cases not covered by the above policy.
  #
  def load_csv
    puts "=============================="
    puts "** Loading CSVs from: #{dir}"
    puts "=============================="
    tables = connection.list_tables()

    files = Dir[dir+"/*.csv"].sort
    files.each do |file|
      table = File.basename file, ".csv"
      filename = File.basename file
      csv = FasterCSV.open file, "r"
      if !tables.include? table
        puts "Skip #{filename}"
        next
      end
      puts "Loading #{filename} into #{table}"

      # fields in csv file
      csv_fields = csv.shift
      # fields in db
      tbl_fields = connection.list_fields(table).fetch_fields.map { |f| f.name}
      fields = (csv_fields & tbl_fields)
      ## field_indices is used to pick out the values common to CSV and current schema
      field_indices = fields.map { |c| csv_fields.index c}
      fields = "(#{csv_fields.indices(*field_indices).join(",")})"
      row_length = field_indices.length

      connection.query("delete from #{table}")
      insert = "INSERT INTO #{table} #{fields} VALUES"
      c = 0
      rows = []
      csv.each do |row|
        c += 1
        fields=field_indices.map do |i|
          v=row[i]
          if v.nil?
            '""'
          else
            "'#{Mysql.quote(v)}'"
          end
        end.join(",")
        rows << "(#{fields})"

        ## do one insert per 1000 rows
        if c % 1000 == 0
          putc "."
          if c % 10000 == 0
            puts "\t#{c}"
          end
          $stdout.flush
          sql_str = "#{insert} #{rows.join(",")}"
          connection.query(sql_str) unless c == 0
          rows = []
        end
      end
      sql_str = "#{insert} #{rows.join(",")}"
      connection.query(sql_str) unless rows.empty?
      csv.close
     end

  end

  def load_schema
    d = dir + "/schema.rb"
    puts "=============================="
    puts "** Loading Schema from: #{d}"
    puts "=============================="
    ENV["SCHEMA"] = d
    Rake::Task["db:reset"].invoke
  end

end


# UGLY helper to convert the original yml data to csv.
# class YAMLDumper < DBDumper
#   include MySQLConnection
#   DEV_DATA = File.expand_path(RAILS_ROOT+"/db/dev_data")
#
#   def load
#     files=Dir["#{DEV_DATA}/*.yml"]
#     files.each do |file|
#       table = File.basename(file, ".yml")
#       puts "Loading #{table}"
#       records=YAML::parse(ERB.new(File.read(file)).result).transform.values
#       connection.query "delete from #{table}"
#       records.each do |r|
#         #row=record.values[0]
#         fields=[]
#         values=[]
#         r.each do |k,v|
#           if v
#             fields << k
#             values << "\"#{v}\""
#           end
#         end
#         sql = <<EOF
# INSERT INTO #{table} (#{fields.join(",")})
# VALUES (#{values.join(",")})
# EOF
#         connection.query sql
#       end
#     end
#   end
# end


namespace :data do
  namespace :csv do
    desc "dump table data into <table>.csv."
    task :dump do
      CSVDumper.dump ENV["DUMP"]
    end

    desc "load csv data."
    task :load do
      CSVDumper.load ENV["DUMP"]
    end
  end
end

namespace :donortrust do
  desc "do migration and load development data from dev_data"
  task :migrate do
    Rake::Task["db:migrate"].invoke
    ENV["DUMP"] = "#{RAILS_ROOT}/db/dev-data"
    Rake::Task["data:csv:load_data"].invoke
  end
end

