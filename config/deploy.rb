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

set :runner, user
set :admin_runner, runner

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

# role :web, "your web-server here"                          # Your HTTP server, Apache/etc
# role :app, "your app-server here"                          # This may be the same as your `Web` server
# role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end


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

after 'deploy:update_code', 'symlink:config'