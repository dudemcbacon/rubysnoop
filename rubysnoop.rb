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

  @@progress = {}

  get '/' do
    erb :index  
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
    
    id = session['session_id']
    if @@progress[id].nil?
      puts "is nil"
      @@progress[id] = {}
      @@progress[id]['total'] = hosts.count
      @@progress[id]['current'] = 0
    else
      puts "is not nil"
      r = {'success' => false, 'error' => 'Scan already in progress...'}
      return JSON.generate(r)
    end

    thr = Thread.new do
      hosts.each_with_index do |host,index|
        @@progress[id]['current'] = index+1
        puts index
        sleep(3) 
        #nmap = Scanner.new
     
        #if nmap.scan(host, ports, "scan.xml")
        #  @scan = nmap.parse("scan.xml")
        #end 
    
        #File.delete("scan.xml")
      end
    end

    r = {'success' => 'true', 'info' => "scanning #{hosts.count} host(s)..."}
    JSON.generate(r)
    #erb :results
  end
 
  get '/get_progress' do
    JSON.generate(@@progress[session['session_id']])
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
