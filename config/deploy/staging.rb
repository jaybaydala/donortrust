set :rails_env, "staging"
set :branch, "release/1.8.0"
# set :deploy_via, :checkout
set :rvm_ruby_string, "ree@#{application}_#{rails_env}"
set :deploy_to, "/var/www/apps/#{application}_#{rails_env}"

set :stage, "staging.uend.org"
role :app, stage
role :admin, stage
role :web, stage
role :db, stage, :primary => true
role :schedule, stage

namespace :deploy do
  task :update_crontab, :roles => :schedule do
    # don't do anything on the staging server - no crontab for now
  end
end
