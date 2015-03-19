require 'active_record'
require 'yaml'
require 'cgi'
require 'uri'
require 'eventmachine'
require 'grape'
require 'agile_proxy/api/root'
require 'agile_proxy/servers/api'
require 'agile_proxy/servers/request_spec'
require 'agile_proxy/servers/request_spec_direct'
require 'forwardable'

require 'goliath/api'
require 'goliath/runner'

# Example demonstrating how to use a custom Goliath runner
#

class Custom < Goliath::API
  def response(env)
    [200, {}, "hello!"]
  end
end



module AgileProxy
  #
  # This class is responsible for controlling the underlying proxy and web servers
  #
  class Server
    ROOT = File.expand_path '../../', File.dirname(__FILE__)
    extend Forwardable
    attr_reader :request_handler

    def_delegators :request_handler, :reset_cache, :restore_cache, :handle_request

    def initialize
      environment = AgileProxy.config.environment
      dbconfig    = YAML.load(File.read(AgileProxy.config.database_config_file)).with_indifferent_access
      ActiveRecord::Base.configurations = dbconfig
      ActiveRecord::Base.establish_connection dbconfig[environment.to_s]
    end

    # Starts the proxy and web servers
    def start
      main_loop
    end

    # The url that the proxy server is running on
    # @return [String] The URL
    def url
      "http://#{host}:#{port}"
    end

    # The url that the web server can be accessed from
    # @return [String] The URL
    def webserver_url
      "http://#{webserver_host}:#{webserver_port}"
    end

    # The url that the direct web server can be accessed from
    # @return [String] The URL
    def server_url
      "http://#{server_host}:#{server_port}"
    end

    # The host that the proxy server is running on
    # @return [String] The host
    def host
      'localhost'
    end

    # The port that the proxy server is running on
    # @return [String] The port
    def port
      @request_spec_server.port
    end

    # The host that the webserver is running on
    # @return [String] The host
    def webserver_host
      AgileProxy.config.webserver_host
    end

    # The port that the webserver is running on
    # @return [String] The port
    def webserver_port
      AgileProxy.config.webserver_port
    end

    # The host that the direct server is running on
    # @return [String] The host
    def server_host
      AgileProxy.config.server_host
    end

    # The port that the direct server is running on
    # @return [String] The port
    def server_port
      AgileProxy.config.server_port
    end

    protected

    def main_loop
      EM.run do
        EM.error_handler do |e|
          puts e.class.name, e
          puts e.backtrace.join("\n")
        end
        AgileProxy::Servers::Api.start(webserver_host, webserver_port)
        AgileProxy::Servers::RequestSpecDirect.start(server_host, server_port)
        @request_spec_server = AgileProxy::Servers::RequestSpec.start enable_cache: AgileProxy.config.enable_cache
        AgileProxy.log(:info, "agile-proxy: Proxy listening on #{url}, API webserver listening on #{webserver_url} and Direct webserver listening on #{server_url}")
      end
    end
  end
end
