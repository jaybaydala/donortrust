set :repository,  "git@github.com:jaybaydala/donortrust.git"
set :branch, "staging"

set :mongrel_conf, "/etc/mongrel_cluster/uend_staging.yml"
set :mongrel_admin_conf, "/etc/mongrel_cluster/uend_staging_admin.yml"
set :mongrel_clean, true
set :mongrel_rails, "mongrel_rails"

set :scm, :git
set :deploy_via, :checkout
set :git_enable_submodules, 1

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :port, 422

set :stage, "staging"
set :rails_env, "staging"
set :deploy_to, "/home/uend/apps/#{application}_#{rails_env}"
set :stage, "staging.uend.org"
role :app, stage
role :admin, stage
role :web, stage
role :db, stage, :primary => true
role :schedule, stage

namespace :deploy do
  desc <<-DESC
  symlink the images, stylesheets and javascripts to current_path
  DESC
  task :asset_folder_fix , :roles => :web do
    %w( stylesheets system javascripts ).each do |dir|
      asset_path = "#{latest_release}/public/#{dir}"
      server_path = "/var/www/staging.uend.org/#{dir}"
      send(run_method, "rm -f #{server_path}")
      send(run_method, "ln -s #{asset_path} #{server_path}")
    end
    # keep backward-compatibility for images/uploaded_pictures
    dir = "images/uploaded_pictures"
    server_path = "/var/www/staging.uend.org/#{dir}"
    asset_path = "#{latest_release}/public/system/uploaded_pictures"
    send(run_method, "rm -f #{server_path}")
    send(run_method, "ln -s #{asset_path} #{server_path}")
    
    image_paths = ["active_scaffold", "bus_admin", "calendar.gif", "dt", "rails.png", "redbox_spinner.gif"]
    image_paths.each do |image|
      asset_path = "#{latest_release}/public/images/#{image}"
      server_path = "/var/www/staging.uend.org/images/#{image}"
      send(run_method, "rm -f #{server_path}")
      send(run_method, "ln -s #{asset_path} #{server_path}")
    end
  end
  
  task :update_crontab, :roles => :schedule do
    # don't do anything on the staging server - no crontab for now
  end
end
