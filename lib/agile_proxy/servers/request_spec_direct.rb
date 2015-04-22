require 'rack'
require 'goliath/api'
require 'goliath/runner'
module AgileProxy
  module Servers
    #
    # The API Server
    #
    # This server is a RACK server responsible for providing access to the system
    # using REST requests.
    # This allows remote programming of the proxy using either a client adapter or the built in user interface
    module RequestSpecDirect
      ROOT = Dir.pwd
      class << self
        #
        # Starts the server on the given host and port
        # @param server_host [String] The host for the server to run on
        # @param server_port [Integer] The port for the server to run on
        def start(server_host, server_port, static_dirs = [])

          runner = ::Goliath::Runner.new([], nil)
          runner.address = server_host
          runner.port = server_port
          notFoundApp = -> {[404, {}, 'Not Found']}
          runner.app = ::Goliath::Rack::Builder.app do
            map '/' do
              run ::Rack::Cascade.new([::Rack::Static.new(notFoundApp, root: ROOT, urls: [''], index: 'index.html'), ::AgileProxy::StubHandler.new])
            end
          end
          runner.run
        end
      end
    end
  end
end
