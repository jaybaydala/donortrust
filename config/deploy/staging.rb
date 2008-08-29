# this is a configuration for Dreamhost's Passenger 
# - it shouldn't get back into the 1-2-stable branch or trunk
set :stage, "staging"
set :deploy_to, "/home/pivot/dt.pivotib.com/apps/#{application}"
set :domain, "dt.pivotib.com"
set :user, "pivot"
set :rails_env, "staging"
set :use_sudo, false
role :app, domain
role :admin, domain
role :web, domain
role :db, domain, :primary => true
role :schedule, domain

namespace :deploy do
  task :cold do
    update
    migrate
    start
  end

  task :start,    :roles => :app do
    # do nothing
  end
  task :stop,    :roles => :app do
    # do nothing
  end
  task :restart,  :roles => :app do
    run "touch {release_path}/tmp/restart.txt"
  end
  task :start_admin,    :roles => :app do
    # do nothing
  end
  task :stop_admin,    :roles => :app do
    # do nothing
  end
  task :restart_admin,  :roles => :app do
    # do nothing
  end
  
  task :after_update_code, :roles => :app do
    run <<-CMD
      mv #{release_path}/config/backgroundrb.yml.staging #{release_path}/config/backgroundrb.yml
    CMD
    run <<-CMD
      cd #{release_path} && rake deploy_edge REVISION=#{rails_version} 
    CMD
  end
  
  task :start_backgroundrb , :roles => :schedule do
    # don't do anything on the staging server - backgroundrb isn't running for now
  end
  task :stop_backgroundrb , :roles => :schedule do
    # don't do anything on the staging server - backgroundrb isn't running for now
  end
  task :restart_backgroundrb , :roles => :schedule do
    # don't do anything on the staging server - backgroundrb isn't running for now
  end
  
end
