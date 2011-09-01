require "config/environment"
 
use Rails::Rack::LogTailer
# use ActionDispatch::Static
run ActionController::Dispatcher.new