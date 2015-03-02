require 'faraday'
require 'agile_proxy/cli'
require 'socket'




module AgileProxy
  module TestServer
    class DummyApi
      def response(env)
        [200, {}, "hello!"]
      end
    end
    class Server
      attr_accessor :server_port
      def initialize(world)
        @world = world
        at_exit do
          cleanup
        end
        #Thin::Logging.silent = true
      end
      def pids
        @pids ||= []
      end
      def cleanup
        until pids.empty?
          begin
            Process.kill('INT', pids.pop);
          rescue Errno::ESRCH
            #Do nothing
          end
        end
      end
      def available_port(qty = 1)
        # use Addrinfo
        results = []
        sockets_opened = []
        while results.length < qty
          socket = Socket.new(:INET, :STREAM, 0)
          socket.bind(Addrinfo.tcp("127.0.0.1", 0))
          port = socket.local_address.ip_port
          results.push port unless results.include? port
          sockets_opened.push socket
        end
        sockets_opened.each do |socket|
          socket.close
        end
        results
      end

      def ruby
        RbConfig.ruby
      end
      def start_test_servers
        ports = available_port(3)
        puts "Starting test server on #{ports[0]}"
        pids.push spawn(ruby, "echo_server.rb", '--address', 'localhost', '--port', "#{ports[0]}")
        puts "Starting test server on #{ports[1]}"
        pids.push spawn(ruby, "echo_server.rb", '--address', 'localhost', '--port', "#{ports[1]}", '--ssl')
        puts "Starting test server on #{ports[2]}"
        pids.push spawn({'STATUS_CODE' => '500'}, ruby, "echo_server.rb", '--address', 'localhost', '--port', "#{ports[2]}")
        @world.instance_eval do
          @http_url  = "http://localhost:#{ports.shift}"
          @https_url = "https://localhost:#{ports.shift}"
          @error_url = "http://localhost:#{ports.shift}"
          @http_url_no_proxy = "http://localhost:#{server_port}"
          @https_url_no_proxy = "https://localhost:#{server_port}"
        end
      end


    end

    def initialize(rspecParams=nil)

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
      @test_servers = Server.new(self)
      @test_servers.server_port = server_port
      @test_servers.start_test_servers
    end

    def start_proxy_server
      Thread.new do
        cli = Cli.start(['start', proxy_port.to_s, server_port.to_s, api_port.to_s, '--env', 'test'])
      end
      sleep 10
    end


  end
end
