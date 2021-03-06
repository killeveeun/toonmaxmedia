set :application, "toonmaxmedia"
set :domain,      "69.164.193.254"
set :repository,  "git@github.com:AlexChien/toonmaxmedia.git"
set :use_sudo,    false
set :deploy_to,   "/var/local/www/#{application}"
set :scm,         "git"
set :user,        "runner"
set :runner,      "nobody"

# Whatever you set here will be taken set as the default RAILS_ENV value
# on the server. Your app and your hourly/daily/weekly/monthly scripts
# will run with RAILS_ENV set to this value.
set :rails_env, "production"

# NOTE: for some reason Capistrano requires you to have both the public and
# the private key in the same folder, the public key should have the
# extension ".pub".
ssh_options[:keys] = ["#{ENV['HOME']}/.ssh/id_rsa"]

set :scm, :git
set :scm_verbose, true
set :branch, "master"

set :repository, "git@github.com:AlexChien/toonmaxmedia.git"
set :deploy_via, :remote_cache

role :app, domain
role :web, domain
role :db,  domain, :primary => true

namespace :deploy do
  
  desc "Generate database.yml and Create asset packages for production, minify and compress js and css files"
  after "deploy:update_code", :roles => [:web] do
    # database_yml
    # asset_packager
  end
  
  # add soft link script for deploy
  desc "Symlink the upload directories"
  after "deploy:symlink", :roles => [:web] do
    # link cache directory
    run "ln -nfs #{deploy_to}/#{shared_dir}/cache #{deploy_to}/#{current_dir}/public/cache"

    migrate
  end  
  
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  desc "Generate Production database.yml"
  task :database_yml, :roles => [:web] do
    db_config = "#{shared_path}/config/database.yml.production"
    run "cp #{db_config} #{release_path}/config/database.yml"
  end
  
  desc "Create asset packages for production, minify and compress js and css files"
  task :asset_packager, :roles => [:web] do
    run <<-EOF
    cd #{current_release} && rake RAILS_ENV=production asset:packager:build_all
    EOF
  end
  
  
end