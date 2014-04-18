#!/usr/bin/env ruby
require 'nmap/base'
require 'nmap/xml'

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
      nmap.syn_scan = true
      nmap.service_scan = true
      nmap.os_fingerprint = true
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
    ports = []
    Nmap::XML.new('scan.xml') do |xml|
      xml.each_host do |host|
        "[#{host.ip}]"
        
        host.each_port do |port|
          if port.service.to_s == "http"
             print get_title "http://#{host.ip}:#{port.number}"
          end
          ports.push(port)
        end
      end
    end

    return ports
  end
end
