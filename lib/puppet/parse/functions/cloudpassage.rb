#! /usr/bin/ruby

require 'rubygems'
require 'httparty'

class Cloudpassage
  include HTTParty
  headers 'x-cpath-access' => '0c800e1b5c45c626201765546bb683e2'
  base_uri = 'https://portal.cloudpassage.com/api/1/servers'
  puts self.get(base_uri)
end

Cloudpassage.new()
