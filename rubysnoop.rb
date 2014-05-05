#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/scanner.rb'

require 'rubygems'
require 'erb'
require 'nmap/program'
require 'nmap/xml'
require 'pry'
require 'ipaddress'
require 'resolv'
require 'sinatra/base'
require 'sinatra/flash'

class RubySnoop < Sinatra::Base
  set :bind, '0.0.0.0'
  set :static, true
  set :public_folder, Proc.new { File.join(root, "static") }
  
  enable :sessions
  register Sinatra::Flash

  get '/' do
    erb :index  
  end

  post '/scan_one' do
    target = params[:address]
    ports = params[:ports]

    begin
      host = IPAddress::IPv4.new target
      if host.count != 1
        r = {'success' => false, 'error' => "IP address string must represent exactly one IP address."}
        JSON.generate(r)
      else
        r = {'succes' => true, 'scan_object' => "blah", 'ip_address' => target}
        JSON.generate(r)
      end
    rescue ArgumentError
      r = {'success' => false, 'error' => "Unable to parse IP Address: #{target}"}
      JSON.generate(r)
    end
  end

  post '/scan' do
    target = params[:address]
    ports = params[:ports]
    
    begin
      hosts = IPAddress.parse target
    rescue ArgumentError
      flash[:error] = "Yo dawg, that address is wacky; lets go eat some laffy taffy!"
      redirect '/' 
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
