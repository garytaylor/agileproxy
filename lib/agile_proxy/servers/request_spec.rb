require 'eventmachine'
module AgileProxy
  module Servers
    #
    # The 'Request Spec' server
    # This server is responsible for handling or passing through a request, depending
    # on if it has a matching 'Request Specification'
    class RequestSpec
      # Starts the server
      def self.start
        new.start
      end
      def initialize
        @request_handler = AgileProxy::RequestHandler.new
      end
      # Starts the server
      def start
        @signature = EM.start_server('127.0.0.1', AgileProxy.config.proxy_port, ProxyConnection) do |p|
          p.handler = @request_handler
        end
        self
      end
      # The port the server is running on
      # @return [Integer] The port the server is running on
      def port
        Socket.unpack_sockaddr_in(EM.get_sockname(@signature)).first
      end
    end
  end
end
