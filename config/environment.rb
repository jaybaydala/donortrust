# The app is set to production by default - this is for capistrano purposes - CM
ENV['RAILS_ENV'] ||= 'development'

RAILS_GEM_VERSION = '1.2.3' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')
require 'fastercsv'
Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  #if ENV['RAILS_ENV'] != 'production' && ENV['RAILS_ENV'] != 'staging'
  config.action_controller.session_store = :active_record_store
  #end

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
  
  # install user_observer for authenticated_mailer 
  # install gift_observer for gift_notifier
  config.active_record.observers = :user_observer, :tax_receipt_observer

  # Add vendor/gems into the load path so we can unpack gems and keep them local
  config.load_paths += Dir["#{RAILS_ROOT}/vendor/gems/**"].map do |dir| 
    File.directory?(lib = "#{dir}/lib") ? lib : dir
  end
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile
Mime::Type.register "application/pdf", :pdf

# Include your application configuration below

#if ENV['RAILS_ENV'] == 'production' || ENV['RAILS_ENV'] == 'staging'
#  # using SQLSessionStore because it's really fast...
#  ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.update(:database_manager => SqlSessionStore)
#  SqlSessionStore.session_class = MysqlSession
#end

# add in a readable date format
ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(:dt_default => "%b %e, %Y")

require 'rubygems'
require 'flickr'
require 'ruby_tube'

MY_KEY='dce9d80477ea833b9dd029bc5f0eceea'
class Flickr
 alias old_initialize initialize
 def initialize(api_key=MY_KEY, email=nil, password=nil)
   old_initialize(api_key, email, password)
    @host="http://api.flickr.com"
    @activity_file='flickr_activity_cache.xml'
  end
end

YOU_TUBE_KEY = 'BayCH1FukEw'
class RubyTube
  alias old_initialize initialize
  def initialize(you_tube_key=YOU_TUBE_KEY)
    old_initialize(you_tube_key)
  end
end

#This supports the need to create an ActiveRecord object from XML
#Basically, we are just re-opening the module definition. This
#This functionality will now be available as a class method for 
#any ActiveRecord object
require "rexml/document"
module ActiveRecord
  class Base
    def self.rehydrate_from_xml(xml)
      xml = REXML::Document.new(xml) if xml.class == String

      ar = self.new
      xml.elements[1].elements.each do | ele |
        sym = ele.name.underscore.to_sym

        # An association
        if ele.has_elements?
          if self.reflect_on_association(sym)
            klass = self.reflect_on_association(sym).klass
            ar.send sym, klass.rehydrate_from_xml(ele)
          end
        # An attribute
        else
          ar[sym] = ele.text
        end
      end

      return ar
    end
  end
end