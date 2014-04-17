require 'erb'
require 'nmap/program'
require 'nmap/xml'
require 'pry'
require 'ipaddress'
require 'sinatra'

set :bind, '0.0.0.0'

get '/index' do
  @thing = 'butt'
  erb :index  
end

post '/scan' do
  @host = {}
  @host['address'] = params[:address] 
  @host['ports'] = []
  
  if !IPAddress.valid? @host['address']
    return "Pleas enter a valid IP address."
  end 
   
  Nmap::Program.scan do |nmap|
    nmap.syn_scan = true
    nmap.service_scan = true
    nmap.os_fingerprint = true
    nmap.xml = 'scan.xml'
    nmap.verbose = true

    nmap.ports = [80, 8080]
    nmap.targets = params[:address]
  end

  Nmap::XML.new('scan.xml') do |xml|
    xml.each_host do |host|
      "[#{host.ip}]"
      
      host.each_port do |port|
        if port.service.to_s == "http"
           print get_title "http://#{host.ip}:#{port.number}"
        end
        binding.pry
        @host['ports'].push(port)
      end
    end
  end
  erb :results
end

helpers do
  def get_title(url)
    return url #Mechanize.new.get(url).title    
  end
end
