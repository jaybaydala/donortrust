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

after "deploy:update_code" do
  deploy.link_configs
  thinking_sphinx.symlink_sphinx_indexes
  thinking_sphinx.restart
end
after "deploy:symlink", "deploy:update_crontab" # this happens after the symlink and, therefore, after bundler
after "deploy:restart", "deploy:cleanup"

namespace :thinking_sphinx do
  task :symlink_sphinx_indexes, :roles => :app do
    run "rm -rf #{latest_release}/db/sphinx && ln -nfs #{shared_path}/sphinx #{latest_release}/db/sphinx"
  end
end

namespace :deploy do
  task :live_upload, :roles => :app do
    upload
    restart
  end

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
    run "rm -f #{release_path}/config/database.yml && ln -s #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
    run "ln -nfs #{shared_path}/config/omniauth.yml #{latest_release}/config/omniauth.yml"
    # initializers
    run "ln -nfs #{shared_path}/config/initializers/mongrel.rb #{latest_release}/config/initializers/mongrel.rb"
    run "ln -nfs #{shared_path}/config/initializers/recaptcha_vars.rb #{latest_release}/config/initializers/recaptcha_vars.rb"
  end
  
  desc "Update the crontab file"
  task :update_crontab, :roles => :schedule do
    run "cd #{latest_release} && bundle exec whenever --set environment=#{rails_env} --update-crontab #{application}"
  end
end


namespace :web do
  task :disable do
    on_rollback { run "rm #{shared_path}/system/maintenance.html" }
    template = File.read(File.join(File.dirname(__FILE__), "..", "public", "maintenance.html"))
    put template, "#{shared_path}/system/maintenance.html", :mode => 0644
  end

  task :enable, :roles => :web, :except => { :no_release => true } do
    run "rm #{shared_path}/system/maintenance.html"
  end
end