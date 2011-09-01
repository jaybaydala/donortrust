set :rails_env, "production"
set :stage, "production"
set :branch, "staging"
set :rvm_ruby_string, "ree@#{application}_#{rails_env}"
set :deploy_to, "/var/www/apps/#{application}_#{rails_env}"

set :algea, "www.uend.org"
role :app, algea
role :admin, algea
role :web, algea
role :db, algea, :primary => true
role :schedule, algea

namespace :deploy do
end
