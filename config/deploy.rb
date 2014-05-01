require 'rvm/capistrano'
require 'bundler/capistrano'

# RVM Setup
set :rvm_ruby_string, :local 
set :rvm_autolibs_flag, "read-only"

# SCM Setup
set :scm, :git
set :repository,  'git@github.com:dudemcbacon/rubysnoop.git'
set :branch, 'master'
set :deploy_via, :remote_cache
set :ssh_options, { :forward_agent => true }

# Application Setup
set :application, 'rubysnoop'
set :user, 'deploy'
set :deploy_to, '/srv/www/scan.awesomeindustries.net'

# Role Setup
role :web, 'scan.awesomeindustries.net'
role :app, 'scan.awesomeindustries.net' 

before 'deploy:setup', 'rvm:install_rvm'
before 'deploy:setup', 'rvm:install_ruby'

after "deploy:cold" do
  admin.nginx_restart
end


