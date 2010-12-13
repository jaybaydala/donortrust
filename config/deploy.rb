require 'config/environment'
require 'capistrano/ext/multistage'
require 'mongrel_cluster/recipes'
set :bundle_without, [:development, :test, :cucumber]
require "bundler/capistrano"

set :application, "donortrust"

set :stages, %w( staging production )
set :default_stage, "staging"

set :repository,  "git@github.com:jaybaydala/donortrust.git"
set :branch, "master"

set :keep_releases, 5

set :scm, :git
set :deploy_via, :remote_cache
set :git_enable_submodules, 1

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :port, 422

set :mongrel_clean, true
set :mongrel_rails, "mongrel_rails"

set :user, "ideaca"
set :group, "users"

after "deploy:update_code", "deploy:configure_stuff"

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
    configure_ultrasphinx
    update_crontab
  end

  task :link_configs do
    run "ln -nfs #{shared_path}/config/iats.yml #{latest_release}/config/iats.yml"
    run "ln -nfs #{shared_path}/config/aws.yml #{latest_release}/config/aws.yml"
    run "ln -nfs #{shared_path}/config/recaptcha_vars.rb #{latest_release}/config/initializers/recaptcha_vars.rb"
    run "rm -f #{release_path}/config/database.yml && ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  
  desc <<-DESC
  Configure Ultrasphinx for deployment environment
  DESC
  task :configure_ultrasphinx, :roles => :app do
    ["#{stage}.conf"].each do |config|
      run "rm -f #{release_path}/config/ultrasphinx/#{config} && ln -s #{shared_path}/config/ultrasphinx/#{config} #{release_path}/config/ultrasphinx/#{config}"
    end
  end 
  
  task :asset_folder_fix, :roles => :web do
    # to be defined by multistage deployment files
  end

  desc "Update the crontab file"
  task :update_crontab, :roles => :schedule do
    run "cd #{latest_release} && whenever --set environment=#{rails_env} --update-crontab #{application}"
  end

  task :setup_mongrel_cluster do
    sudo "cp #{current_path}/config/mongrel_cluster.yml #{mongrel_conf}"
    sudo "chown mongrel:www-data #{mongrel_conf}"
    sudo "chmod g+w #{mongrel_conf}"
  end 
end

desc <<-DESC
Check the status of all mongrel processes
DESC
task :status,  :roles => :app do mongrel.cluster.status end
