require "rvm/capistrano"
require 'bundler/capistrano'
require 'capistrano_colors'

set :rvm_ruby_string, "ruby-1.9.3"

set :application, "File Server"
set :user, "system"

set :scm, :git
set :repository,  "git@github.com:PeterWuMC/file_server.git"

set :deploy_to, "/home/system/file_server" # path to app on remote machine
set :domain, 'peterwumc.asuscomm.com'
set :port, 2232
set :use_sudo, false
role :app, domain
role :web, domain
role :db, domain, :primary => true

set :runner, user
set :admin_runner, runner

namespace :symlink do
  task :config, :roles => :app, :except => { :no_release => true } do
    run "ln -nfs #{shared_path}/config/setup.yml #{release_path}/config/setup.yml"
    run "ln -nfs #{shared_path}/thin/production_config.yml #{release_path}/thin/production_config.yml"
  end
end

namespace :deploy do
  task :start, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup thin -C thin/production_config.yml -R thin/config.ru start"
  end

  task :stop, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup thin -C thin/production_config.yml -R thin/config.ru stop"
  end

  task :restart, :roles => [:web, :app] do
    deploy.stop
    deploy.start
  end

  # This will make sure that Capistrano doesn't try to run rake:migrate (this is not a Rails project!)
  task :cold do
    deploy.update
    deploy.start
  end
end

after 'deploy:update_code', 'symlink:config', 'deploy:migrate'