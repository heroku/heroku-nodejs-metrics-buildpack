require_relative 'spec_helper'
require 'json'

branch = ENV['HATCHET_BUILDPACK_BRANCH'] || "master"

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
    versions = resolve_node_version(["8.x", "9.x"])
  end

  versions.each do |version|
    context "a single-process node v#{version} app" do
      let(:app) {
        Hatchet::Runner.new(
          "node-metrics-single-process",
          buildpacks: ["heroku/nodejs", "https://github.com/heroku/heroku-nodejs-metrics-buildpack.git#{branch}"]
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

  versions.each do |version|
    context "a multi-process node v#{version} app" do
      let(:app) {
        Hatchet::Runner.new(
          "node-metrics-multi-process",
          buildpacks: ["heroku/nodejs", "https://github.com/heroku/heroku-nodejs-metrics-buildpack.git#{branch}"]
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
    versions = resolve_node_version(["8.x", "9.x"])
  end

  versions.each do |version|
    context "a multi-process node v#{version} app" do
      let(:app) {
        Hatchet::Runner.new(
          "node-metrics-test-app",
          buildpacks: ["heroku/nodejs", "https://github.com/heroku/heroku-nodejs-metrics-buildpack.git#{branch}"]
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
          "node-metrics-single-process",
          buildpacks: ["heroku/nodejs", "https://github.com/heroku/heroku-nodejs-metrics-buildpack.git#{branch}"]
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

