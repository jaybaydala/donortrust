ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'
require 'rspec_hpricot_matchers'

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  config.include RspecHpricotMatchers
  
  # == Notes
  # 
  # For more information take a look at Spec::Example::Configuration and Spec::Runner
end
# quiet down any migrations
ActiveRecord::Migration.verbose = false