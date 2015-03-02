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
      ROOT = File.expand_path '../../../', File.dirname(__FILE__)
      class << self
        #
        # Starts the server on the given host and port
        # @param server_host [String] The host for the server to run on
        # @param server_port [Integer] The port for the server to run on
        def start(server_host, server_port, static_dirs = [])

          runner = ::Goliath::Runner.new([], nil)
          runner.address = server_host
          runner.port = server_port
          runner.app = ::Goliath::Rack::Builder.app do
            use Rack::Static, root: File.join(ROOT, 'assets'), urls: static_dirs, index: 'index.html' unless static_dirs.empty?
            map '/' do
              run ::AgileProxy::StubHandler.new
            end
          end
          runner.run
        end
      end
    end
  end
end
