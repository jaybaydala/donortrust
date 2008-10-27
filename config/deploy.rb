require 'config/environment'
require 'capistrano/ext/multistage'
require 'mongrel_cluster/recipes'

set :application, "donortrust"
set :user, "dtrust"

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
  task :after_start do
    start_admin
    start_backgroundrb
  end
  task :after_stop do
    stop_admin
    stop_backgroundrb
  end
  task :before_restart do
    asset_folder_fix
    copy_iats_config
  end
  task :after_restart do
    restart_admin
    restart_backgroundrb
  end

  task :asset_folder_fix , :roles => :web do
    # to be defined by multistage deployment files
  end
  task :before_asset_folder_fix do
    # uploaded pictures
    uploaded_pictures_path = "#{latest_release}/public/images/uploaded_pictures"
    send(run_method, "rm -f #{uploaded_pictures_path} && ln -s #{shared_path}/system/uploaded_pictures #{uploaded_pictures_path}")
  end

  task :setup_mongrel_cluster do
    sudo "cp #{current_path}/config/mongrel_cluster.yml #{mongrel_conf}"
    sudo "chown mongrel:www-data #{mongrel_conf}"
    sudo "chmod g+w #{mongrel_conf}"
  end 
  
  task :copy_iats_config do
    set :iats_conf, "#{current_path}/config/iats.yml"
    sudo "cp #{shared_path}/system/iats.yml #{iats_conf}"
    sudo "chmod a+r #{iats_conf}"
  end
  
  desc <<-DESC
  Start the Backgroundrb daemon on the schedule server.
  DESC
  task :start_backgroundrb , :roles => :schedule do
    cmd = "#{current_path}/script/backgroundrb start"
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
  Restart the Backgroundrb daemon on the app server.
  DESC
  task :restart_backgroundrb , :roles => :app do
    begin stop_backgroundrb; rescue; end #this catches the bdrb error where a PID file doesn't exist
    start_backgroundrb
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
