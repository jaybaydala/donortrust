require 'config/environment'
require 'capistrano/ext/multistage'
require 'mongrel_cluster/recipes'
set :application, "donortrust"
set :repository,  "http://#{application}.rubyforge.org/svn/trunk/"

set :mongrel_conf, "/etc/mongrel_cluster/#{application}.yml"
set :mongrel_admin_conf, "/etc/mongrel_cluster/#{application}_admin.yml"
set :mongrel_clean, true
set :mongrel_rails, "mongrel_rails"

set :stage, "production"
set :deploy_to, "/home/uend/#{application}"
set :user, "ideaca"
set :group, "mongrel"
set :rails_env, "production"
set algea, "10.100.5.229"
role :app, algea
role :admin, algea
role :web, algea
role :db, algea, :primary => true
role :schedule, algea

namespace :deploy do
  task :insert_google_stats, :roles => :app do
    stats = <<-JS
      <script type="text/javascript">
      _uacct = "UA-832237-2";
      urchinTracker();
      </script>
    JS
    layout = "#{latest_release}/app/views/layouts/dt_application.html.erb" 
    run "sed -i 's?<!--googlestats-->?#{stats}?' #{layout}" 
  end

  desc <<-DESC
  symlink the images, system, stylesheets and javascripts to current_path
  DESC
  task :asset_folder_fix , :roles => :web do
    %w( stylesheets system javascripts ).each do |dir|
      asset_path = "#{latest_release}/public/#{dir}"
      server_path = "/var/www/blog.christmasfuture.org/wordpress/#{dir}"
      send(run_method, "rm -f #{server_path}")
      send(run_method, "ln -s #{asset_path} #{server_path}")
    end
    # keep backward-compatibility for images/uploaded_pictures
    dir = "images/uploaded_pictures"
    server_path = "/var/www/blog.christmasfuture.org/wordpress/#{dir}"
    asset_path = "#{latest_release}/public/system/uploaded_pictures"
    send(run_method, "rm -f #{server_path}")
    send(run_method, "ln -s #{asset_path} #{server_path}")

    image_paths = ["active_scaffold", "bus_admin", "calendar.gif", "dt", "rails.png", "redbox_spinner.gif"]
    image_paths.each do |image|
      asset_path = "#{latest_release}/public/images/#{image}"
      server_path = "/var/www/blog.christmasfuture.org/wordpress/images/#{image}"
      send(run_method, "rm -f #{server_path}")
      send(run_method, "ln -s #{asset_path} #{server_path}")
    end
  end
end
