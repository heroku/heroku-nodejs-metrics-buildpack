require_relative 'spec_helper'
require 'json'

branch = ENV['HATCHET_BUILDPACK_BRANCH'] || "master"

# List of "bad" versions of Node
version_blacklist = ["10.2.0"]

describe "Node Metrics Hello World" do

  before(:each) do
    set_node_version(app.directory, node_version)
    app.setup!
    app.set_config({
      "HEROKU_METRICS_URL" => "http://localhost:3000",
      "METRICS_INTERVAL_OVERRIDE" => "10000"
    })
  end

  if ENV['TEST_ALL_NODE_VERSIONS'] == 'true'
    versions = resolve_all_supported_node_versions()
  else 
    versions = resolve_node_version(["8.x", "9.x", "10.x"])
  end

  versions.each do |version|
    context "a single-process node v#{version} app" do
      let(:app) {
        Hatchet::Runner.new(
          "node-metrics-single-process",
          buildpacks: ["heroku/nodejs", "https://github.com/heroku/heroku-nodejs-metrics-buildpack.git##{branch}"]
        )
      }
      let(:node_version) { version }
      it "should deploy" do
        app.deploy do |app|
          expect(app.output).to include("-----> Build succeeded!")
          expect(app.output).to include("HerokuNodejsRuntimeMetrics app detected")
          if version_blacklist.include? version
            expect(successful_body(app).strip).to eq("not found")
          else
            expect(successful_body(app).strip).to eq("--require /app/.heroku/node-metrics-plugin")
          end
        end
      end
    end
  end

  versions.each do |version|
    context "a multi-process node v#{version} app" do
      let(:app) {
        Hatchet::Runner.new(
          "node-metrics-multi-process",
          buildpacks: ["heroku/nodejs", "https://github.com/heroku/heroku-nodejs-metrics-buildpack.git##{branch}"]
        )
      }
      let(:node_version) { version }
      it "should deploy" do
        app.deploy do |app|
          expect(app.output).to include("-----> Build succeeded!")
          expect(app.output).to include("HerokuNodejsRuntimeMetrics app detected")
          expect(successful_body(app).strip).to eq("Hello, world!")
        end
      end
    end
  end
end

describe "Node Metrics" do

  before(:each) do
    set_node_version(app.directory, node_version)
    app.setup!
    app.set_config({
      "HEROKU_METRICS_URL" => "http://localhost:3000",
      "METRICS_INTERVAL_OVERRIDE" => "10000"
    })
  end

  if ENV['TEST_ALL_NODE_VERSIONS'] == 'true'
    versions = resolve_all_supported_node_versions()
  else 
    versions = resolve_node_version(["8.x", "9.x", "10.x"])
  end

  versions.each do |version|
    # Skip tests if this version is in the blacklist
    next if version_blacklist.include? version

    context "a multi-process node v#{version} app" do

      let(:app) {
        Hatchet::Runner.new(
          "node-metrics-test-app",
          buildpacks: ["heroku/nodejs", "https://github.com/heroku/heroku-nodejs-metrics-buildpack.git##{branch}"]
        )
      }

      let(:node_version) { version }
      it "should deploy" do
        app.deploy do |app|
          expect(app.output).to include("-----> Build succeeded!")
          expect(app.output).to include("HerokuNodejsRuntimeMetrics app detected")
          data = successful_json_body(app)
          expect(data["gauges"]["node.eventloop.delay.ms.max"]).to  be >= 2000
        end
      end
    end
  end
end

describe "Unsupported Node version" do 

  before(:each) do
    set_node_version(app.directory, node_version)
    app.setup!
    app.set_config({
      "HEROKU_METRICS_URL" => "http://localhost:3000",
      "METRICS_INTERVAL_OVERRIDE" => "10000"
    })
  end

  ["6.0.0"].each do |version|
    context "Unsupported Node v#{version} app" do
      let(:app) {
        Hatchet::Runner.new(
          "node-metrics-multi-process",
          buildpacks: ["heroku/nodejs", "https://github.com/heroku/heroku-nodejs-metrics-buildpack.git##{branch}"]
        )
      }

      let(:node_version) { version }
      it "should deploy" do
        app.deploy do |app|
          expect(app.output).to include("-----> Build succeeded!")
          expect(app.output).to include("HerokuNodejsRuntimeMetrics app detected")
          expect(app.output).to include("The Heroku Node.js Metrics Plugin does not support Node v#{version}")
          expect(app.output).to include("https://devcenter.heroku.com/articles/language-runtime-metrics-nodejs")
          expect(successful_body(app).strip).to eq("Hello, world!")
        end
      end
    end
  end
end

describe "Don't overwrite NODE_OPTIONS" do
  before(:each) do
    set_node_version(app.directory, node_version)
    app.setup!
    app.set_config({
      "HEROKU_METRICS_URL" => "http://localhost:3000",
      "METRICS_INTERVAL_OVERRIDE" => "10000",
      "NODE_OPTIONS" => "--max-old-space-size=500"
    })
  end

  resolve_node_version(["8.x"]).each do |version|
    context "Don't overwrite NODE_OPTIONS v#{version}" do
      let(:app) {
        Hatchet::Runner.new(
          "node-metrics-single-process",
          buildpacks: ["heroku/nodejs", "https://github.com/heroku/heroku-nodejs-metrics-buildpack.git##{branch}"]
        )
      }

      let(:node_version) { version }
      it "should deploy" do
        app.deploy do |app|
          expect(app.output).to include("-----> Build succeeded!")
          expect(app.output).to include("HerokuNodejsRuntimeMetrics app detected")
          expect(app.output).to include("NODE_OPTIONS: --max-old-space-size=500")
          expect(successful_body(app).strip).to eq("--max-old-space-size=500 --require /app/.heroku/node-metrics-plugin")
        end
      end
    end
  end
end

describe "Unsupported Node version" do 

  before(:each) do
    set_node_version(app.directory, node_version)
    app.setup!
    app.set_config({
      "HEROKU_METRICS_URL" => "http://localhost:3000",
      "METRICS_INTERVAL_OVERRIDE" => "10000"
    })
  end

  ["10.2.0"].each do |version|
    context "Blacklisted Node v#{version} app" do
      let(:app) {
        Hatchet::Runner.new(
          "node-metrics-multi-process",
          buildpacks: ["heroku/nodejs", "https://github.com/heroku/heroku-nodejs-metrics-buildpack.git##{branch}"]
        )
      }

      let(:node_version) { version }
      it "should deploy" do
        app.deploy do |app|
          expect(app.output).to include("-----> Build succeeded!")
          expect(app.output).to include("HerokuNodejsRuntimeMetrics app detected")
          expect(app.output).to include("Node v10.2.0 is not supported by the Heroku Metrics plugin")
          expect(successful_body(app).strip).to eq("Hello, world!")
        end
      end
    end
  end
end