require 'vendor/gems/mongrel_cluster-1.0.3/lib/mongrel_cluster/recipes'
set :application, "donortrust"
set :repository,  "http://#{application}.rubyforge.org/svn/tags/rel_1-1-2"
set :deploy_via, :export

set :deploy_to, "/home/dtrust/#{application}"
set :user, "dtrust"
set :rails_env, "production"

set :mongrel_conf, "/etc/mongrel_cluster/#{application}.yml"
set :mongrel_admin_conf, "/etc/mongrel_cluster/#{application}_admin.yml"
set :mongrel_clean, true

role :app, "slice2.christmasfuture.org"
role :admin, "slice2.christmasfuture.org"
role :web, "slice.christmasfuture.org"
role :db,  "slice.christmasfuture.org", :primary => true
role :schedule,  "slice2.christmasfuture.org"

namespace :deploy do

  task :cold do
    update
    migrate
    setup_mongrel_cluster
    start
  end

  # until mongrel_cluster updates to cap2...
  task :start,    :roles => :app do start_mongrel_cluster end
  task :stop,     :roles => :app do stop_mongrel_cluster end
  task :restart,  :roles => :app do restart_mongrel_cluster end
  
  # donortrust hooks
  task :after_start do start_admin end
  task :after_stop do stop_admin end
  task :after_restart do restart_admin end
  task :before_deploy do stop_backgroundrb end
  task :after_deploy do start_backgroundrb end
  task :before_migrations do stop_backgroundrb end
  task :after_migrations do start_backgroundrb end
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
  task :before_restart do
    asset_folder_fix
    install_backgroundrb
  end

  task :setup_mongrel_cluster do
    sudo "cp #{current_path}/config/mongrel_cluster.yml #{mongrel_conf}"
    sudo "chown mongrel:www-data #{mongrel_conf}"
    sudo "chmod g+w #{mongrel_conf}"
  end 
  
  desc <<-DESC
  Install backgrounDRB since it's incompatible with windows boxes
  DESC
  task :install_backgroundrb, :roles => :schedule do
    cmd = "svn co -q http://svn.devjavu.com/backgroundrb/tags/release-0.2.1 #{current_path}/vendor/plugins/backgroundrb;"
    run cmd
  end
  
  desc <<-DESC
  Start the Backgroundrb daemon on the schedule server.
  DESC
  task :start_backgroundrb , :roles => :schedule do
    cmd = "#{current_path}/script/backgroundrb start -- -r #{rails_env}"
    send(run_method, cmd)
  end

  desc <<-DESC
  Restart the Backgroundrb daemon on the schedule server.
  DESC
  task :restart_backgroundrb , :roles => :schedule do
    cmd = "#{current_path}/script/backgroundrb restart"
    send(run_method, cmd)
  end

  desc <<-DESC
  Stop the Backgroundrb daemon on the schedule server.
  DESC
  task :stop_backgroundrb , :roles => :schedule do
    cmd = "#{current_path}/script/backgroundrb stop"
    send(run_method, cmd)
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

  task :start_admin , :roles => :admin do
    cmd = "#{mongrel_rails} cluster::start -C #{mongrel_admin_conf}"
    cmd += " --clean" if mongrel_clean    
    send(run_method, cmd)
  end
  task :restart_admin , :roles => :admin do
    cmd = "#{mongrel_rails} cluster::restart -C #{mongrel_admin_conf}"
    cmd += " --clean" if mongrel_clean    
    send(run_method, cmd)
  end
  task :stop_admin , :roles => :admin do
    cmd = "#{mongrel_rails} cluster::stop -C #{mongrel_admin_conf}"
    cmd += " --clean" if mongrel_clean    
    send(run_method, cmd)
  end
end

desc <<-DESC
Check the status of all mongrel processes
DESC
task :status,  :roles => :app do status_mongrel_cluster end
task :after_status , :roles => :admin do
  send(run_method, "#{mongrel_rails} cluster::status -C #{mongrel_admin_conf}")
end


# THESE ARE TO HELP MOVE THE PRODUCTION DB TO YOUR DEV ENVIRONMENT
# to use, do this: `rake db:production_data_refresh`
desc 'Dumps, downloads and then cleans up the production data dump'
task :remote_db_runner do
  remote_db_dump
  remote_db_download
  remote_db_cleanup
end

desc 'Dumps the #{rails_env} database to db/#{rails_env}_data.sql on the remote server'
task :remote_db_dump, :roles => :db, :only => { :primary => true } do
  run "cd #{deploy_to}/current && " +
    "rake RAILS_ENV=#{rails_env} db:database_dump --trace" 
end

desc 'Downloads db/#{rails_env}_data.sql from the remote environment to your local machine'
task :remote_db_download, :roles => :db, :only => { :primary => true } do  
  execute_on_servers(options) do |servers|
    self.sessions[servers.first].sftp.connect do |tsftp|
      tsftp.get_file "#{deploy_to}/current/db/#{rails_env}_data.sql", "db/production_data.sql" 
    end
  end
end

desc 'Cleans up data dump file'
task :remote_db_cleanup, :roles => :db, :only => { :primary => true } do
  run "rm -f #{deploy_to}/current/db/#{rails_env}_data.sql"
end 
