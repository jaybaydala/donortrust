require 'config/environment'
require 'capistrano/ext/multistage'
require 'mongrel_cluster/recipes'
set :application, "donortrust"
set :repository,  "http://#{application}.rubyforge.org/svn/trunk/"

set :mongrel_conf, "/etc/mongrel_cluster/#{application}.yml"
set :mongrel_admin_conf, "/etc/mongrel_cluster/#{application}_admin.yml"
set :mongrel_clean, true

set :stage, "production"
set :deploy_to, "/home/dtrust/#{application}"
set :user, "dtrust"
set :rails_env, "production"
role :app, "slice2.christmasfuture.org"
role :admin, "slice2.christmasfuture.org"
role :web, "slice.christmasfuture.org"
role :db,  "slice.christmasfuture.org", :primary => true
role :schedule,  "slice2.christmasfuture.org"

namespace :deploy do
  task :after_update_code, :rols => :app do
    run <<-CMD
      cd #{release_path} && rake deploy_edge REVISION=#{rails_version} 
    CMD
    run <<-CMD
      mv #{release_path}/config/backgroundrb.yml.production #{release_path}/config/backgroundrb.yml
    CMD
    run <<-CMD
      cd #{release_path} && rake deploy_edge REVISION=#{rails_version} 
    CMD
  end

  task :after_symlink, :roles => :app do
    stats = <<-JS
      <script type="text/javascript">
      _uacct = "UA-832237-2";
      urchinTracker();
      </script>
    JS
    layout = "#{current_path}/app/views/layouts/dt_application.rhtml" 
    run "sed -i 's?<!--googlestats-->?#{stats}?' #{layout}" 
  end

  desc <<-DESC
  symlink the images, stylesheets and javascripts to current_path
  DESC
  task :asset_folder_fix , :roles => :web do
    cmd = ""
    %w( stylesheets javascripts ).each do |dir|
      asset_path = "#{latest_release}/public/#{dir}"
      server_path = "/var/www/wp.christmasfuture.org/#{dir}"
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
