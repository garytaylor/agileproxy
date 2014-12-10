require 'require_all'

require 'agile_proxy'
require_all 'spec/support/**/*.rb'
require_all 'lib/agile_proxy/model'
require_all 'spec/integration/helpers'
require 'faker'
RSpec.configure do |config|
  config.include AgileProxy::TestServer, :type => :integration
  config.before :all, :type => :integration do
    start_test_servers
    start_proxy_server
  end

end
