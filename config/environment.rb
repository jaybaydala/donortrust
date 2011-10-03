ENV['RAILS_ENV'] ||= 'development'

RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')
require 'fastercsv'

require 'rack/rewrite' # apparently bundler hasn't required it just yet...

Rails::Initializer.run do |config|
  config.middleware.insert_before(Rack::Lock, Rack::Rewrite) do
    r301 '/dt/accounts', '/iend'
    r301 '/dt/accounts/new', '/iend/users/new'
    r301 '/dt/accounts/reset', '/iend/password_resets'
    r301 %r{/blog/?.*}, 'http://blog.uend.org/'
    # rewrite '/blog/Example_Path', '/foo'
    # r302 '/wiki/Another_Example', '/bar'
    # r301 %r{/wiki/(\w+)_\w+}, '/$1'
  end
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.autoload_paths += %W( #{RAILS_ROOT}/extras )
  %w(mailers sweepers observers).each do |path|
    config.autoload_paths += %W( #{Rails.root}/app/#{path} )
  end
  

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
  config.plugins = [ :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]
  config.frameworks -= [ :active_resource ]
  
  # Specify gems that this application depends on.
  # They can then be installed with "rake gems:install" on new installations.
  
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
  config.active_record.observers = :user_observer, :tax_receipt_observer, :searchbar_sweeper, :upowered_sweeper
  
  # Add vendor/gems into the load path so we can unpack gems and keep them local
  #config.load_paths += Dir["#{RAILS_ROOT}/vendor/gems/**"].map do |dir|
  #  File.directory?(lib = "#{dir}/lib") ? lib : dir
  #end
end
