ENV['RAILS_ENV'] ||= 'development'

RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

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
  config.frameworks -= [ :active_resource ]
  
  # Specify gems that this application depends on.
  # They can then be installed with "rake gems:install" on new installations.
  config.gem "mislav-will_paginate", :lib => "will_paginate", :source => "http://gems.github.com"
  config.gem "RedCloth", :lib => "redcloth", :source => "http://code.whytheluckystiff.net/"
  config.gem "calendar_date_select"
  config.gem "activemerchant", :lib => "active_merchant"
  # RSS Feed parsing
  config.gem "simple-rss"
  config.gem "feed-normalizer"
  config.gem "hpricot", :source => "http://code.whytheluckystiff.net"
  # social application gems
  config.gem "flickr"
  # pdf creation gems
  config.gem "pdf-writer", :lib => "pdf/writer"
  config.gem "transaction-simple", :lib => "transaction/simple"
  config.gem "color-tools", :lib => "color"
  # scheduling
  config.gem 'javan-whenever', :lib => false, :version => ">=0.3.0", :source => 'http://gems.github.com'
  # bad bots
  config.gem "ruby-recaptcha"
  
  
  #calendar_date_select
  #config.gem "timcharper-calendar_date_select", :version => "1.11", :source => "http://gems.github.com", :lib => "gem_init"
  
  # Only load the plugins named here, in the order given. By default, all plugins
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
  config.plugins = [ :all ]
  
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
  config.action_controller.session = {
    :session_key => '_donortrustfe_session_id',
    :secret      => '4000cc1a0b91489bd5eb5b3ef9ccd2f250e6a50ebb11c100e24d74dceba8a73df871a292f89a2f2a93cce98e4b0f91e50ccc626fd6d2cee640696fcff08ae597'
  }
  
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

recaptcha_file = File.join(RAILS_ROOT, "public", "system", "recaptcha_vars.rb")
require recaptcha_file if File.exists?(recaptcha_file)

# set up the Exception Notifier plugin
ExceptionNotifier.exception_recipients = %w(sysadmin@pivotib.com, info@christmasfuture.org)
ExceptionNotifier.sender_address = %("DT Application Error" <support@christmasfuture.com>)
ExceptionNotifier.email_prefix = "[DT ERROR] "

#The url to the GroundSpring US donations page
GROUNDSPRING_URL = 'https://secure.groundspring.org/dn/index.php?aid=21488'

ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(:dt_default => "%b %e, %Y")

require 'deliver_to_admins_only'

class Flickr
  DT_KEY = "dce9d80477ea833b9dd029bc5f0eceea"
  def initialize_with_key(api_key=nil, email=nil, password=nil)
    api_key = Flickr::DT_KEY if api_key.nil?
    initialize_without_key(api_key, email, password)
    @host="http://api.flickr.com"
    @activity_file='flickr_activity_cache.xml'
  end
  alias_method_chain :initialize, :key
end

class RubyTube
  DT_KEY =  "BayCH1FukEw"
  def initialize_with_key(api_key)
    api_key = RubyTube::DT_KEY if api_key.nil?
    initialize_without_key(api_key)
  end
  alias_method_chain :initialize, :key
end

require 'bleak_house' if ENV['BLEAK_HOUSE']

#
#unless '1.9'.respond_to?(:force_encoding)
#  String.class_eval do
#    begin
#      remove_method :chars
#    rescue NameError
#      # OK
#    end
#  end
#end