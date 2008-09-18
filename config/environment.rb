# The app is set to production by default - this is for capistrano purposes - CM
ENV['RAILS_ENV'] ||= 'development'

RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')
require 'fastercsv'
Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on. 
  # They can then be installed with "rake gems:install" on new installations.
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem "chronic", :version => "0.2.3"
  config.gem "aslakhellesoy-cucumber", :version => ">= 0.1.5", :source => "http://gems.github.com", :lib => "cucumber"
  config.gem "daemons", :version => ">= 1.0.10"
  config.gem "feed-normalizer", :version => "1.4.0"
  config.gem "flickr", :version => "1.0.0"
  config.gem "highline", :version => "1.4.0"
  config.gem "hoe"
  config.gem "hpricot", :source => "http://code.whytheluckystiff.net"
  config.gem "mocha", :version => "0.5.5"
  config.gem "mongrel", :version => "1.1.5"
  config.gem "mislav-will_paginate", :version => ">= 2.3.2", :lib => "will_paginate", :source => "http://gems.github.com"
  config.gem "packet", :version => "0.1.10"
  config.gem "pdf-writer", :version => ">= 1.1.3", :lib => "pdf/writer"
  config.gem "RedCloth", :version => ">= 3.301", :source => "http://code.whytheluckystiff.net/"
  config.gem "rfacebook", :version => "0.9.8"
  config.gem "rspec_hpricot_matchers", :version => "1.0"
  config.gem "RubyTube", :version => "0.1.0", :lib => "ruby_tube"
  config.gem "simple-rss", :version => "1.1"
  config.gem "transaction-simple", :version => ">= 1.4.0", :lib => "pdf/writer"
  config.gem "color-tools", :version => ">= 1.3.0", :lib => "color"

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
  # config.plugins = [ :active_scaffold, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Uncomment to use default local time.
  config.time_zone = 'Mountain Time (US & Canada)'

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  # config.action_controller.session = {
  #   :session_key => '_donortrust_session',
  #   :secret      => '4000cc1a0b91489bd5eb5b3ef9ccd2f250e6a50ebb11c100e24d74dceba8a73df871a292f89a2f2a93cce98e4b0f91e50ccc626fd6d2cee640696fcff08ae597'
  # }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  config.active_record.observers = :user_observer, :tax_receipt_observer, :searchbar_sweeper

  # Add vendor/gems into the load path so we can unpack gems and keep them local
  #config.load_paths += Dir["#{RAILS_ROOT}/vendor/gems/**"].map do |dir|
  #  File.directory?(lib = "#{dir}/lib") ? lib : dir
  #end
end

#The url to the GroundSpring US donations page
GROUNDSPRING_URL = 'https://secure.groundspring.org/dn/index.php?aid=21488'  

ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(:dt_default => "%b %e, %Y")

require 'deliver_to_admins_only'

MY_KEY='dce9d80477ea833b9dd029bc5f0eceea'
class Flickr
  def initialize_with_key(api_key=MY_KEY, email=nil, password=nil)
    initialize_without_key(api_key, email, password)
    @host="http://api.flickr.com"
    @activity_file='flickr_activity_cache.xml'
  end
  alias_method_chain :initialize, :key
end

YOU_TUBE_KEY = 'BayCH1FukEw'
class RubyTube
  def initialize_with_key(you_tube_key=YOU_TUBE_KEY)
    initialize_without_key(you_tube_key)
  end
  alias_method_chain :initialize, :key
end
