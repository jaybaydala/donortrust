# basic setup
require 'config/environment'
require 'capistrano/ext/multistage'
# RVM setup
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano" # Load RVM's capistrano plugin.
# bundler setup
set :bundle_without, [:development, :test, :cucumber]
require "bundler/capistrano"
# thinking_sphinx setup
require 'thinking_sphinx/deploy/capistrano'

set :application, "donortrust"

set :stages, %w( staging production )
set :default_stage, "staging"

set :repository, "git@github.com:jaybaydala/donortrust.git"
set :branch, "master"

set :keep_releases, 5

set :scm, :git
set :deploy_via, :remote_cache
set :git_enable_submodules, 1

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :port, 422

set :use_sudo, false
set :user, "ideaca"
set :group, "users"

before "deploy:update_code", "thinking_sphinx:stop"
after "deploy:update_code", "thinking_sphinx:configure_and_start"
after "deploy:update_code", "deploy:configure_stuff"
after "deploy:restart", "deploy:cleanup"

namespace :thinking_sphinx do
  task :stop, :roles => :app do
    thinking_sphinx.stop
  end

  task :configure_and_start, :roles => :app do
    symlink_sphinx_indexes
    thinking_sphinx.configure
    thinking_sphinx.start
  end
end

namespace :deploy do
  task :start, :roles => :app do
    #noop
  end
  task :stop, :roles => :app do
    #noop
  end
  task :restart do  
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  # donortrust hooks
  task :configure_stuff do
    link_configs
    update_crontab
  end

  task :link_configs do
    # config
    run "ln -nfs #{shared_path}/config/flickr.yml #{latest_release}/config/flickr.yml"
    run "ln -nfs #{shared_path}/config/iats.yml #{latest_release}/config/iats.yml"
    run "ln -nfs #{shared_path}/config/aws.yml #{latest_release}/config/aws.yml"
    run "rm -f #{release_path}/config/database.yml && ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/omniauth.yml #{latest_release}/config/omniauth.yml"
    # initializers
    run "ln -nfs #{shared_path}/config/initializers/mongrel.rb #{latest_release}/config/initializers/mongrel.rb"
    run "ln -nfs #{shared_path}/config/initializers/recaptcha_vars.rb #{latest_release}/config/initializers/recaptcha_vars.rb"
  end
  
  desc "Update the crontab file"
  task :update_crontab, :roles => :schedule do
    run "cd #{latest_release} && whenever --set environment=#{rails_env} --update-crontab #{application}"
  end
end
