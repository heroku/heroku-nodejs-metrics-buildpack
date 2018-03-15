require_relative 'spec_helper'

describe "Node Metrics" do

  before(:each) do
    set_node_version(app.directory, node_version)
    app.setup!
    # app.set_config(
    #   "JVM_COMMON_BUILDPACK" =>
    #   "https://api.github.com/repos/heroku/heroku-buildpack-jvm-common/tarball/#{jvm_common_branch}")
    `heroku features:enable runtime-heroku-metrics --app #{app.name}`
  end

  ["8.10.0", "6.13.1"].each do |version|
    context "a simple java app on jdk-#{version}" do
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
end
