require 'rspec/core'
require 'hatchet'
require 'fileutils'
require 'hatchet'
require 'rspec/retry'
require 'date'
require 'json'

ENV['RACK_ENV'] = 'test'

RSpec.configure do |config|
  config.filter_run focused: true unless ENV['IS_RUNNING_ON_TRAVIS']
  config.run_all_when_everything_filtered = true
  config.alias_example_to :fit, focused: true
  config.full_backtrace      = true
  config.verbose_retry       = true # show retry status in spec process
  config.default_retry_count = 2 if ENV['IS_RUNNING_ON_TRAVIS'] # retry all tests that fail again

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  #config.mock_with :none
end

def git_repo
  "https://github.com/heroku/heroku-nodejs-metrics-buildpack.git"
end

def set_node_version(directory, version)
  Dir.chdir(directory) do
    package_json = File.open('package.json', 'rb') { |f| f.read }
    package = JSON.parse(package_json)
    package["engines"]["node"] = version
    File.open('package.json', 'w') do |f|
      f.puts JSON.dump(package)
    end
    `git add package.json && git commit -m "setting node version"`
  end
end

def successful_body(app, options = {})
  retry_limit = options[:retry_limit] || 50 
  path = options[:path] ? "/#{options[:path]}" : ''
  Excon.get("http://#{app.name}.herokuapp.com#{path}", :idempotent => true, :expects => 200, :retry_limit => retry_limit).body
end

def successful_json_body(app, options = {})
  body = successful_body(app, options)
  JSON.parse(body)
end

def resolve_node_version(requirements) 
  requirements.map do |requirement|

  end
  # use nodebin to get latest node versions
end
