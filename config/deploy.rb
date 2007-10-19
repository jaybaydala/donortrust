require 'mongrel_cluster/recipes'
set :application, "donortrust"
set :repository,  "http://#{application}.rubyforge.org/svn/trunk/"

set :deploy_to, "/home/dtrust/#{application}"
set :user, "dtrust"
set :rails_env, "development"

set :mongrel_conf, "/etc/mongrel_cluster/#{application}.yml"
set :mongrel_clean, true

role :app, "slice2.christmasfuture.org"
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

  namespace :donortrust do
    desc <<-DESC
    donortrust cold deployment
    DESC
    task :cold do
      transaction do
        update
        migrate
        setup_mongrel_cluster
        install_backgroundrb # it's not included in the repository because of windows incompatibilities
        asset_folder_fix
        start
        #start_backgroundrb
      end
    end

    desc <<-DESC
    donortrust-specific deployment task
    DESC
    task :default do
      stop_backgroundrb
      transaction do
        update # creates the symlink
        install_backgroundrb # it's not included in the repository because of windows incompatibilities
        asset_folder_fix
        restart
      end
      #start_backgroundrb
    end
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
    cmd = "#{current_path}/script/backgroundrb start"
    run cmd
  end

  desc <<-DESC
  Restart the Backgroundrb daemon on the schedule server.
  DESC
  task :restart_backgroundrb , :roles => :schedule do
    cmd = "#{current_path}/script/backgroundrb restart"
    run cmd
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

end