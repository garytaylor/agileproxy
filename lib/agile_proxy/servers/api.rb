require 'rack'
require 'thin'
require 'grape'
require 'agile_proxy/api/root'

module AgileProxy
  module Servers
    #
    # The API Server
    #
    # This server is a RACK server responsible for providing access to the system
    # using REST requests.
    # This allows remote programming of the proxy using either a client adapter or the built in user interface
    module Api
      ROOT = File.expand_path '../../../', File.dirname(__FILE__)
      class << self
        #
        # Starts the webserver on the given host and port
        # @param webserver_host [String] The host for the server to run on
        # @param webserver_port [Integer] The port for the server to run on
        def start(webserver_host, webserver_port)
          # The sinatra web server
          dispatch = Rack::Builder.app do
            use Rack::Static, root: File.join(ROOT, 'assets'), urls: ['/ui'], index: 'index.html'
            map '/api' do
              run ::AgileProxy::Api::Root.new
            end
          end
          # Start the web server.
          ::Rack::Server.start(
              app: dispatch,
              server: 'thin',
              Host: webserver_host,
              Port: webserver_port,
              signals: false
          )
        end
      end
    end
  end
end
