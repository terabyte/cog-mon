#!/usr/bin/env ruby

require 'andand'
require 'awesome_print'
require 'httpclient'

GH=1000*1000*1000
TH=GH*1000

begin

  ELIGIUS_URL = 'http://eligius.st/~wizkid057/newstats/userstats.php/'

  DEVICE_TABLE = {
    '1cogxXyYU2EXEbdcV9j18PWenRU7gAjt1' => {
      'TerraMiner0' => { # device name
        :expected => 1.5*TH, # expected hashrate
        :threshold => 0.6, # threshold to alarm at
      },
      'TerraMiner1' => { # device name
        :expected => 1.5*TH, # expected hashrate
        :threshold => 0.6, # threshold to alarm at
      },
      'TerraMiner2' => { # device name
        :expected => 1.5*TH, # expected hashrate
        :threshold => 0.6, # threshold to alarm at
      },
      'TerraMiner3' => { # device name
        :expected => 1.5*TH, # expected hashrate
        :threshold => 0.6, # threshold to alarm at
      },
      'TerraMiner4' => { # device name
        :expected => 1.5*TH, # expected hashrate
        :threshold => 0.6, # threshold to alarm at
      },
      'TerraMiner5' => { # device name
        :expected => 1.5*TH, # expected hashrate
        :threshold => 0.6, # threshold to alarm at
      },
      'TerraMiner6' => { # device name
        :expected => 1.5*TH, # expected hashrate
        :threshold => 0.6, # threshold to alarm at
      },
      'TerraMiner7' => { # device name
        :expected => 1.5*TH, # expected hashrate
        :threshold => 0.6, # threshold to alarm at
      },
    },
  }

  http = HTTPClient.new
  hashrate_data = {}
  DEVICE_TABLE.each_pair do |address,device_hash|

    hashrate_data[address] = {}

    url = ELIGIUS_URL + address

    content = http.get_content(url)

    state = 0
    miner_name = nil
    content.gsub!("\n", '')

    device_hash.each_pair do |name, hash|
      matches = content.match("#{name}(.*?)22.5 Minutes</I></TD><TD>([^<]+)</TD>")
      next unless matches
      inbetween = matches[1]
      # IN THE GHETTO:
      tr_count = " #{inbetween} ".split('</TR>').length.to_i - 1
      #puts "TR count: #{tr_count}"
      next unless tr_count <= 3
      textrate = matches[2] # e.g. "1.465.23 Gh/s"
      if !textrate.nil?
        hashrate = textrate.match('(.+) Gh/s').andand[1].gsub(',', '').to_i * GH
        #puts "Found miner '#{name}' 22.5 minute average is #{hashrate * 1.0 / GH} GH/s"
        hashrate_data[address][name] = { :hashrate => hashrate }
      end
    end
  end
#  puts "Data:"
#  ap hashrate_data

  # now calculate hashrates and ensure they are adequate
  errors_found = false
  DEVICE_TABLE.each_pair do |address,device_hash|
    device_hash.each_pair do |name, hash|
      hashrate = hashrate_data[address].andand[name].andand[:hashrate].andand.to_f
      if hashrate.nil?
        puts "ERROR: #{name} is not hashing at all!"
        errors_found = true
        next
      end
      if (hash[:expected] * hash[:threshold]) > hashrate
        puts "ERROR: #{name} is hashing at #{hashrate} but #{hash[:expected]} is expected (#{100.0*hashrate / hash[:expected]}%)"
        errors_found = true
      end
    end
  end
  if errors_found
    exit 1
  end
  exit 0
end


