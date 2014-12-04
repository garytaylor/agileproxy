require 'require_all'
require 'airborne'

require 'agile_proxy'
require_all 'spec/support/**/*.rb'
require_all 'lib/agile_proxy/model'
require_all 'spec/integration/helpers'
require 'faker'
RSpec.configure do |config|
  include AgileProxy::TestServer
  config.before :all do
    start_test_servers
  end

end
Airborne.configure do |config|
  config.base_url = 'http://localhost:3020'
end
