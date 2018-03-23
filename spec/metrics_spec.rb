require_relative 'spec_helper'
require 'json'

describe "Node Metrics Hello World" do

  before(:each) do
    set_node_version(app.directory, node_version)
    app.setup!
    `heroku features:enable runtime-heroku-metrics --app #{app.name}`
  end

  ["8.10.0", "6.13.1"].each do |version|
    context "a single-process node v#{version} app" do
      let(:app) {
        Hatchet::Runner.new(
          "node-metrics-single-process",
          buildpacks: ["heroku/nodejs", "https://github.com/heroku/heroku-nodejs-metrics-buildpack"]
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

  ["8.10.0", "6.13.1"].each do |version|
    context "a multi-process node v#{version} app" do
      let(:app) {
        Hatchet::Runner.new(
          "node-metrics-multi-process",
          buildpacks: ["heroku/nodejs", "https://github.com/heroku/heroku-nodejs-metrics-buildpack"]
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

  ["8.10.0", "6.13.1"].each do |version|
    context "a multi-process node v#{version} app" do
      let(:app) {
        Hatchet::Runner.new(
          "node-metrics-test-app",
          buildpacks: ["heroku/nodejs", "https://github.com/heroku/heroku-nodejs-metrics-buildpack"]
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



