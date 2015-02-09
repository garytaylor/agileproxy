require 'eventmachine'
require 'thin'
require 'faraday'
require 'agile_proxy/cli'

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
    def initialize(rspecParams=nil)
      Thin::Logging.silent = true
    end
    def proxy_port
      3101
    end
    def api_port
      3021
    end
    def server_port
      3022
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
      @http_url_no_proxy = "http://localhost:#{server_port}"
      @https_url_no_proxy = "https://localhost:#{server_port}"
    end

    def start_proxy_server
      Thread.new do
        cli = Cli.start(['start', proxy_port.to_s, server_port.to_s, api_port.to_s, '--env', 'test'])
      end
      sleep 1
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
