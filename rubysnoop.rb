#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/scanner.rb'

require 'erb'
require 'nmap/program'
require 'nmap/xml'
require 'pry'
require 'ipaddress'
require 'sinatra/base'
require 'resolv'
require 'sinatra/flash'

class RubySnoop < Sinatra::Base
  set :bind, '0.0.0.0'
  set :static, true
  set :public_folder, Proc.new { File.join(root, "static") }

  get '/index' do
    @thing = 'butt'
    erb :index  
  end

  post '/scan' do
    target = params[:address]
    ports = params[:ports]
    
    begin
      hosts = IPAddress.parse target
    rescue ArgumentError
      flash[:error] = "Please enter a valid IP address or network."
      redirect '/index' 
    end

    if ports.nil?
      return "Please select at least one port."
    end

    nmap = Scanner.new
     
    if nmap.scan(target, ports, "scan.xml")
     @scan = nmap.parse("scan.xml")
    end 
    
    File.delete("scan.xml")

    erb :results
  end

  helpers do  
    def get_title(host, port)
      if port.service.to_s == "http"
        url = "http://#{host.ip}:#{port}"
      elsif port.service.to_s == "https"
        url = "https://#{host.ip}:#{port}"
      else
        return " "
      end
      
      begin
        return "<a href='#{url}'>#{Mechanize.new.get(url).title}</a>"  
      rescue
        return "<a href='#{url}'>Dunno, dawg...</a>"
      end
    end

    def r(ip)
      Resolv.new.getname ip
    end
  end
end
