require 'eventmachine'
require 'goliath/api'
require 'goliath/proxy'
module AgileProxy
  module Servers
    #
    # The 'Request Spec' server
    # This server is responsible for handling or passing through a request, depending
    # on if it has a matching 'Request Specification'
    class RequestSpec

      # Starts the server
      def self.start(options = {})
        new(options).start
      end
      def initialize(options = {})
        @request_handler = AgileProxy::RequestHandler.new enable_cache: options[:enable_cache]
      end
      # Starts the server
      def start
        #
        # The API runner
        runner = ::Goliath::Proxy::Runner.new([], nil)
        runner.address = '127.0.0.1'
        runner.port = AgileProxy.config.proxy_port
        app = @request_handler
        runner.app = app
        runner.run
        self

      end
      # The port the server is running on
      # @return [Integer] The port the server is running on
      def port
        return AgileProxy.config.proxy_port
      end
      private
    end
  end
end
