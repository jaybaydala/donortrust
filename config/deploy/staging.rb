require 'config/environment'
require 'capistrano/ext/multistage'
require 'mongrel_cluster/recipes'
set :application, "donortrust"
set :repository,  "http://#{application}.rubyforge.org/svn/trunk/"

set :stage, "staging"
set :deploy_to, "/home/dtrust/staging/#{application}"
set :user, "dtrust"
set :rails_env, "staging"

role :app, "slice3.christmasfuture.org"
role :admin, "slice3.christmasfuture.org"
role :web, "slice.christmasfuture.org"
role :db,  "slice.christmasfuture.org", :primary => true
role :schedule,  "slice3.christmasfuture.org"

set :mongrel_conf, "/etc/mongrel_cluster/#{application}-staging.yml"
set :mongrel_admin_conf, "/etc/mongrel_cluster/#{application}_admin-staging.yml"
set :mongrel_clean, true

namespace :deploy do

  desc <<-DESC
  symlink the images, stylesheets and javascripts to current_path
  DESC
  task :asset_folder_fix , :roles => :web do
    cmd = ""
    %w( stylesheets javascripts ).each do |dir|
      asset_path = "#{latest_release}/public/#{dir}"
      server_path = "/var/www/staging.christmasfuture.org/#{dir}"
      cmd += " && " unless cmd.empty?
      cmd += "rm -f #{server_path} && ln -s #{asset_path} #{server_path}"
    end
    image_paths = ["active_scaffold", "bus_admin", "calendar.gif", "dt", "rails.png", "redbox_spinner.gif"]
    image_paths.each do |image|
      asset_path = "#{latest_release}/public/images/#{image}"
      server_path = "/var/www/wp.christmasfuture.org/images/#{image}"
      cmd += " && " unless cmd.empty?
      cmd += "rm -f #{server_path} && ln -s #{asset_path} #{server_path}"
    end
    send(run_method, cmd)
  end
end
