# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

ActionController::Base.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache"

ActionMailer::Base.delivery_method = :test

if File.exists?(Rails.root.join('tmp', 'debug.txt'))
  require 'ruby-debug'
  Debugger.wait_connection = true
  Debugger.start_remote
  File.delete(Rails.root.join('tmp', 'debug.txt'))
end
