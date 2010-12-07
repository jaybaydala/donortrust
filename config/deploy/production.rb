set :mongrel_conf, "/etc/mongrel_cluster/uend.yml"
set :mongrel_admin_conf, "/etc/mongrel_cluster/uend_admin.yml"

set :stage, "production"
set :rails_env, "production"
set :deploy_to, "/home/uend/apps/#{application}_#{rails_env}"
set :algea, "www.uend.org"
role :app, algea
role :admin, algea
role :web, algea
role :db, algea, :primary => true
role :schedule, algea


namespace :deploy do
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
