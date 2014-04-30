require 'rubygems'
require 'bundler/setup'
Bundler.require

root_dir = File.direname(__FILE__)
app_file = File.join(root_dir, 'rubysnoop.rb')
require app_file

set :environment, ENV['RACK_ENV'].to_sym
set :root,        root_dir
set :app_file,    app_file
disable :run

run RubySnoop
