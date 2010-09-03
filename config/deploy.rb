require 'config/environment'
require 'capistrano/ext/multistage'
require 'mongrel_cluster/recipes'
set :application, "donortrust"

# set :deploy_via, :remote_cache

set :mongrel_conf, "/etc/mongrel_cluster/#{application}.yml"
set :mongrel_admin_conf, "/etc/mongrel_cluster/#{application}_admin.yml"
set :mongrel_clean, true

set :rails_version, "v2.3.4" unless variables[:rails_version]

# before "deploy:asset_folder_fix", "deploy:remove_uploaded_pictures_folder"
after "deploy:update_code", "deploy:configure_stuff"
# after "deploy:start", "deploy:start_admin"
# after "deploy:stop", "deploy:stop_admin"
# after "deploy:restart", "deploy:restart_admin"

namespace :deploy do

  task :cold do
    update
    migrate
    setup_mongrel_cluster
    start
  end

  task :start,    :roles => :app do mongrel.cluster.start end
  task :stop,     :roles => :app do mongrel.cluster.stop end
  task :restart,  :roles => :app do mongrel.cluster.restart end
  
  # donortrust hooks
  task :configure_stuff do
    link_configs
    asset_folder_fix
    insert_google_stats
    configure_ultrasphinx
    update_crontab
  end

  task :link_configs do
    set :iats_conf, "#{latest_release}/config/iats.yml"
    # sudo "cp #{shared_path}/config/iats.yml #{iats_conf}"
    # sudo "chown #{user}:#{group} #{iats_conf} && chmod a+r #{iats_conf}"
    sudo "ln -s #{shared_path}/config/iats.yml #{iats_conf}"
    
    set :recaptcha_conf, "#{latest_release}/config/initializers/recaptcha_vars.rb"
    sudo "ln -s #{shared_path}/config/recaptcha_vars.rb #{recaptcha_conf}"
    sudo "ln -s #{shared_path}/config/aws.yml #{latest_release}/config/aws.yml"
  end
  
  task :remove_uploaded_pictures_folder, :roles => :web do
    # uploaded pictures
    uploaded_pictures_path = "#{latest_release}/public/images/uploaded_pictures"
    send(run_method, "rm -f #{uploaded_pictures_path} && ln -s #{shared_path}/system/uploaded_pictures #{uploaded_pictures_path}")
  end
  task :asset_folder_fix, :roles => :web do
    # to be defined by multistage deployment files
  end
  task :insert_google_stats, :roles => :app do
    # to be defined by multistage deployment files
  end

  task :setup_mongrel_cluster do
    sudo "cp #{current_path}/config/mongrel_cluster.yml #{mongrel_conf}"
    sudo "chown mongrel:www-data #{mongrel_conf}"
    sudo "chmod g+w #{mongrel_conf}"
  end 

  desc <<-DESC
  Configure Ultrasphinx for deployment environment
  DESC
  task :configure_ultrasphinx, :roles => :app do
    ["#{stage}.conf"].each do |config|
      run "rm -f #{release_path}/config/ultrasphinx/#{config} && ln -s #{shared_path}/config/ultrasphinx/#{config} #{release_path}/config/ultrasphinx/#{config}"
    end
  end 
  
  desc "Update the crontab file"
  task :update_crontab, :roles => :schedule do
    run "cd #{release_path} && whenever --set environment=#{rails_env} --update-crontab #{application}"
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
task :status,  :roles => :app do mongrel.cluster.status end
after "status", "admin_status"
task :admin_status , :roles => :admin do
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
