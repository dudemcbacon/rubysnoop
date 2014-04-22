#!/usr/bin/env ruby
require 'nmap/program'
require 'nmap/xml'
require 'mechanize'

class Scanner
  
  # Public: Scan target on specified ports.
  #
  # target    - The String IP address to be targeted
  # ports     - The Array of ports to be scanned.
  # filename  - The String scan output filename.  
  #
  # Examples
  #
  #   scan("127.0.0.1", [80, 8080], "scan.xml")
  #   # => true
  #
  # Returns true if scan completed successfully.
  def scan(target, ports, filename)
    Nmap::Program.scan do |nmap|
      nmap.syn_scan = false
      nmap.service_scan = false
      nmap.os_fingerprint = false
      nmap.xml = filename
      nmap.verbose = true

      nmap.ports = ports
      nmap.targets = target
    end
  end

  # Public: Parse nmap scan output file.
  #
  # filename  - The String scan output filename.
  #
  # Examples
  #
  #   parse("scan.xml")
  #   # => [80, 8080]
  #
  # Returns an array of nmap port types.
  def parse(file)
    hosts = []
    Nmap::XML.new('scan.xml') do |xml|
      xml.each_host do |host|
        current_host = { 'hostname' => host }
        ports = []
        host.each_port do |port|
          # TODO: find a better way to do this...  
          if port.service.to_s == "http" || port.service.to_s == "https"
            port.define_singleton_method(:title) do
              url = "http://#{host.ip}:#{port.number}"
              Mechanize.new.get(url).title
            end
          else
            port.define_singleton_method(:title) do
              ""
            end
          end
          ports.push(port)
        end
        current_host['ports'] = ports
        hosts.push(current_host)
      end
    end
    hosts
  end
  
  # Public: Get the title of a webpage given a URL.
  #
  # url - The String URL.
  #
  # Examples
  #
  #   get_title "http://www.google.com"
  #   # => "Google"
  #
  # Returns a string title.
  def get_title(url)
    Mechanize.new.get(url).title
  end
end
