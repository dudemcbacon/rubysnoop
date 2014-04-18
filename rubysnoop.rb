#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/scanner.rb'

require 'erb'
require 'nmap/program'
require 'nmap/xml'
require 'pry'
require 'ipaddress'
require 'sinatra/base'


class RubySnoop < Sinatra::Base
  set :bind, '0.0.0.0'

  get '/index' do
    @thing = 'butt'
    erb :index  
  end

  post '/scan' do
    target = params[:address]

    @host = {}
    @host['address'] = target
    @host['ports'] = []
    
    if !IPAddress.valid? @host['address']
      return "Pleas enter a valid IP address."
    end 
   
    nmap = Scanner.new
     
    if nmap.scan(target, [80, 8080], "scan.xml")
      @host['ports'] = nmap.parse("scan.xml")
    end 

    erb :results
  end

  helpers do
    def get_title(url)
      return url #Mechanize.new.get(url).title    
    end
  end
end
