require 'logger'
require 'tmpdir'
# Agile Proxy
module AgileProxy
  #
  # Configuration for the agile proxy
  class Config
    DEFAULT_WHITELIST = ['127.0.0.1', 'localhost']
    RANDOM_AVAILABLE_PORT = 0 # https://github.com/eventmachine/eventmachine/wiki/FAQ#wiki-can-i-start-a-server-on-a-random-available-port

    attr_accessor :logger, :cache, :cache_request_headers, :whitelist, :path_blacklist, :ignore_params,
                  :persist_cache, :ignore_cache_port, :non_successful_cache_disabled, :non_successful_error_level,
                  :non_whitelisted_requests_disabled, :cache_path, :proxy_port, :proxied_request_inactivity_timeout,
                  :proxied_request_connect_timeout, :dynamic_jsonp, :dynamic_jsonp_keys,
                  :webserver_host, :webserver_port, :database_config_file, :environment

    def initialize
      @logger = defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
      reset
    end

    # Resets the configuration with the defaults
    def reset
      @cache = true
      @cache_request_headers = false
      @whitelist = DEFAULT_WHITELIST
      @path_blacklist = []
      @ignore_params = []
      @persist_cache = false
      @dynamic_jsonp = false
      @dynamic_jsonp_keys = ['callback']
      @ignore_cache_port = true
      @non_successful_cache_disabled = false
      @non_successful_error_level = :warn
      @non_whitelisted_requests_disabled = false
      @cache_path = File.join(Dir.tmpdir, 'agile-proxy')
      @proxy_port = RANDOM_AVAILABLE_PORT
      @proxied_request_inactivity_timeout = 10 # defaults from https://github.com/igrigorik/em-http-request/wiki/Redirects-and-Timeouts
      @proxied_request_connect_timeout = 5
      @webserver_port = 3020
      @webserver_host = 'localhost'
      @database_config_file = File.join(File.dirname(__FILE__), '..', '..', 'config.yml')
      @environment = ENV['AGILE_PROXY_ENV']
    end
  end

  # Configures the system using a block which has the global instance of this config yielded
  def self.configure
    yield config if block_given?
    config
  end

  # Common log method - sends the log to the appropriate place
  def self.log(*args)
    config.logger.send(*args) unless config.logger.nil?
  end

  private

  def self.config
    @config ||= Config.new
  end
end
