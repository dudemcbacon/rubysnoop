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
    ports = params[:ports]
    
    @host = {}
    @host['address'] = target
    @host['ports'] = []
    
    begin
      hosts = IPAddress.parse target
    rescue ArgumentError
      return "Please enter a valid IP address or network."
    end

    #if !IPAddress.valid? @host['address']
    #  return "Pleas enter a valid IP address."
    #end 
   
    nmap = Scanner.new
     
    if nmap.scan(target, ports, "scan.xml")
     @hosts = nmap.parse("scan.xml")
    end 
    
    File.delete("scan.xml")

    erb :results
  end

  helpers do
    def get_title(url)
      return url #Mechanize.new.get(url).title    
    end
  end
end
