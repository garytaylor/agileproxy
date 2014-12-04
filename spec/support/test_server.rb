require 'eventmachine'
require 'thin'
require 'faraday'

module Thin
  module Backends
    class TcpServer
      def get_port
        # seriously, eventmachine, how hard does getting a port have to be?
        Socket.unpack_sockaddr_in(EM.get_sockname(@signature)).first
      end
    end
  end
end

module AgileProxy
  module TestServer
    def initialize
      Thin::Logging.silent = true
    end

    def start_test_servers
      q = Queue.new
      Thread.new do
        EM.run do
          echo = echo_app_setup

          http_server = start_server(echo)
          q.push http_server.backend.get_port

          https_server = start_server(echo, true)
          q.push https_server.backend.get_port

          echo_error = echo_app_setup(500)
          error_server = start_server(echo_error)
          q.push error_server.backend.get_port
        end
      end

      @http_url  = "http://localhost:#{q.pop}"
      @https_url = "https://localhost:#{q.pop}"
      @error_url = "http://localhost:#{q.pop}"
    end

    def echo_app_setup(response_code = 200)
      counter = 0
      proc do |env|
        req_body = env['rack.input'].read
        request_info = "#{env['REQUEST_METHOD']} #{env['PATH_INFO']}"
        res_body = request_info
        res_body += "\n#{req_body}" unless req_body.empty?
        counter += 1
        [
          response_code,
          { 'HTTP-X-EchoServer' => request_info,
            'HTTP-X-EchoCount' => "#{counter}" },
          [res_body]
        ]
      end
    end

    def start_server(echo, ssl = false)
      http_server = Thin::Server.new '127.0.0.1', 0, echo
      if ssl
        http_server.ssl = true
        http_server.ssl_options = {
          private_key_file: File.expand_path('../../fixtures/test-server.key', __FILE__),
          cert_chain_file: File.expand_path('../../fixtures/test-server.crt', __FILE__)
        }
      end
      http_server.start
      http_server
    end
  end
end
