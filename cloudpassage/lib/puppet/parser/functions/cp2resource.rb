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
    report = self.class.get @uri, self.auth_headers
    issue = Hash.new
    report['sca']['findings'].each do |findings|
      findings['details'].each do |check|
        if check['type'] && check['target'] && check.delete('status') == 'bad'
          title = "#{check.delete('type')}:#{check["config_key"]}:#{check['target']}"
          issue[title] = Hash.new
          issue[title]['message'] = "This will eventually be converted into a resource for remediation:\n"
          check.each_pair do |key, value|
            issue[title]['message'] = issue[title]['message'] +  "#{key} => #{value}\n"
          end
        end
      end
    end
    return issue
  end
end

def hash2resource(title, hash)
  resource = Puppet::Parser::Resource.new('notify', 'title', :scope => self, :source => @main)
  hash.each do |param, value|
    resource.set_parameter(param, value) unless %w{type title}.include?(param)
  end
  resource
end

def create(hash)
  issue.each_pair do |title, hash|
    resource = hash2resource(title, hash)
    self.compiler.add_resource(self, resource)
  end 
end

module Puppet::Parser::Functions
  newfunction(:cp2resource) do |args| 
    issues = Cloudpassage.new(args[0], args[1], args[2]).get_issues
    issues.each do |issue|
      pp issue
      #create(issue)
    end
  end
end
