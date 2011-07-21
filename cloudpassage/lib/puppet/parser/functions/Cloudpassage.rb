#!/usr/bin/ruby

require 'rubygems'
require 'httparty'
require 'pp'

class Cloudpassage
  include HTTParty
  attr_accessor :server_id, :api_key, :base_url  
  def initialize ( server_id, api_key, base_url)
    @uri = "#{base_url}/#{server_id}/issues" 
    @api_key = api_key
  end
  def auth_headers 
    self.class.headers 'x-cpauth-access' => @api_key
  end
  def default_format 
    self.class.format json
  end
  def get_issues
    issues = [] 
    report = self.class.get @uri, self.auth_headers
    report['sca']['findings'].each do |findings|
      issue = {} 
      findings['details'].each do |check|
        if check['type'] && check['target'] && check.delete('status') == 'bad'
          issue['message'] = "This will eventually be converted into a resource for remediation:\n"
          issue['title'] = "#{check.delete('type')}:#{check["config_key"]}:#{check['target']}"
          check.each_pair do |key, value| 
            issue['message'] = issue['message'] +  "#{key} => #{value}\n" 
          end
          issues.push issue
        end
      end
    end   
    return issues
  end
end

#server_id = 'e089d56e7b885cb45a1b327371f14a66'
#api_key = '356627e0c628808b4349b0e44899e114'
#uri = 'https://portal.cloudpassage.com/api/1/servers'
#Cloudpassage.new(server_id, api_key, uri).get_issues
#report.get_issues['sca']['findings'].each do |finding|
#  pp finding 
#  puts "\n########################################\n"
#end
