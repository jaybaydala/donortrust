require 'config/environment'
require 'capistrano/ext/multistage'
require 'mongrel_cluster/recipes'
set :application, "donortrust"
set :repository,  "http://#{application}.rubyforge.org/svn/trunk/"

set :mongrel_conf, "/etc/mongrel_cluster/#{application}-staging.yml"
set :mongrel_admin_conf, "/etc/mongrel_cluster/#{application}-staging_admin.yml"
set :mongrel_clean, true
set :mongrel_rails, "/opt/ruby-enterprise/bin/mongrel_rails"

set :stage, "staging"
set :deploy_to, "/home/dtrust/#{application}_staging"
set :user, "dtrust"
set :group, "dtrust"
set :rails_env, "staging"
set :slice1, "205.206.170.8"
set :slice2, "205.206.170.9"
role :app, slice2
role :admin, slice2
role :web, slice1
role :db, slice2, :primary => true
role :schedule, slice2

namespace :deploy do
  desc <<-DESC
  symlink the images, stylesheets and javascripts to current_path
  DESC
  task :asset_folder_fix , :roles => :web do
    %w( stylesheets javascripts images/uploaded_pictures ).each do |dir|
      asset_path = "#{latest_release}/public/#{dir}"
      server_path = "/var/www/staging.christmasfuture.org/#{dir}"
      send(run_method, "rm -f #{server_path}")
      send(run_method, "ln -s #{asset_path} #{server_path}")
    end
    image_paths = ["active_scaffold", "bus_admin", "calendar.gif", "dt", "rails.png", "redbox_spinner.gif"]
    image_paths.each do |image|
      asset_path = "#{latest_release}/public/images/#{image}"
      server_path = "/var/www/staging.christmasfuture.org/images/#{image}"
      send(run_method, "rm -f #{server_path}")
      send(run_method, "ln -s #{asset_path} #{server_path}")
    end
  end
  
  task :update_crontab, :roles => :schedule do
    # don't do anything on the staging server - no crontab for now
  end
end
