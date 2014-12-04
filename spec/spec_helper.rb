Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }
ENV['RACK_ENV'] ||= 'test'
require 'pry'
require 'active_record'
require 'shoulda-matchers'
require 'rack'
require 'logger'
require_relative './unit/agile_proxy/api/common_helper'
require_relative './common_helper'
require_relative '../lib/agile_proxy'
environment = 'test'
dbconfig    = YAML.load(File.read(AgileProxy.config.database_config_file))
ActiveRecord::Base.establish_connection dbconfig[environment]

AgileProxy.configure do |config|
  config.logger = Logger.new(File.expand_path('../../log/test.log', __FILE__))
end

RSpec.configure do |config|
  include AgileProxy::TestServer
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'

  config.before :all do
    start_test_servers
  end

  config.after :each do
    AgileProxy.config.reset
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end
  config.include AgileProxy::Test::Api::Common, api_test: true
  config.include AgileProxy::Test::Common
end
