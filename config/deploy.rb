require 'mongrel_cluster/recipes'
set :application, "donortrust"
set :repository,  "svn+ssh://sterrym@rubyforge.org/var/svn/#{application}/trunk"

set :deploy_to, "/home/dtrust/#{application}"
set :user, "dtrust"

set :mongrel_conf, "/etc/mongrel_cluster/#{application}.yml"
set :mongrel_clean, true

role :app, "slice.christmasfuture.org"
role :web, "slice.christmasfuture.org"
role :db,  "slice.christmasfuture.org", :primary => true

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
      update
      migrate
      setup_mongrel_cluster
      start
      start_backgroundrb
    end

    desc <<-DESC
    donortrust-specific deployment task
    DESC
    task :default do
      transaction do
        update
        restart_backgroundrb
        restart
      end
    end
  end

  task :setup_mongrel_cluster do
    sudo "cp #{release_path}/config/mongrel_cluster.yml #{mongrel_conf}"
    sudo "chown mongrel:www-data #{mongrel_conf}"
    sudo "chmod g+w #{mongrel_conf}"
  end
  
  desc <<-DESC
  Start the Backgroundrb daemon on the app server.
  DESC
  task :start_backgroundrb , :roles => :web do
    cmd = "#{release_path}/script/backgroundrb start"
    send(run_method, cmd)
  end

  desc <<-DESC
  Restart the Backgroundrb daemon on the app server.
  DESC
  task :restart_backgroundrb , :roles => :web do
    cmd = "#{release_path}/script/backgroundrb restart"
    send(run_method, cmd)
  end

  desc <<-DESC
  Stop the Backgroundrb daemon on the app server.
  DESC
  task :stop_backgroundrb , :roles => :web do
    cmd = "#{release_path}/script/backgroundrb stop"
    send(run_method, cmd)
  end

end