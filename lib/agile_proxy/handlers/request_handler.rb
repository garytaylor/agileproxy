require 'agile_proxy/model/application'
require 'agile_proxy/model/recording'
require 'rack'
require 'forwardable'
require 'agile_proxy/rack/get_only_cache'
module AgileProxy
  #
  # =The Central Request Handler
  #
  # As a request is made from the client to the server via the proxy server, it comes through an instance of this class.
  #
  # This class will then pass the request on to the StubHandler, then finally the ProxyHandler
  class RequestHandler
    extend Forwardable
    include Handler

    def_delegators :stub_handler, :stub

    def initialize(options = {})
      @options = options
    end
    # A rack endpoint
    #
    # This method is called as a rack endpoint and returns a rack response.
    #
    # @param env [Hash] The 'rack' environment
    # @return [Array] The rack response (status, headers, content)
    def call(env)
      request = ActionDispatch::Request.new(env)
      username, password = username_password env
      application = Application.where(username: username, password: password).first
      body = request.body.read
      request.body.rewind
      rack_response = rack_app.call(env)
      if rack_response[0] == 404
        rack_response = [
          500,
          {},
          "Connection to #{request.url}#{body} not stubbed and new http connections are disabled"
        ]
      end
      request_spec = env['agile_proxy.request_spec']
      exclude_headers = ['@env', 'rack.errors', 'rack.logger']
      if application.record_requests || (request_spec && request_spec.record_requests)
        application.recordings.create request_headers: request.headers.reject {|key, value| exclude_headers.include?(key)},
                                      request_body: body,
                                      request_url: request.url,
                                      request_method: request.request_method,
                                      response_headers: rack_response[1],
                                      response_body: rack_response[2],
                                      response_status: rack_response[0],
                                      request_spec_id: request_spec ? request_spec.id : nil
      end
      rack_response
    end

    private

    def rack_app
      stub_handler = stub_handler_app
      proxy_handler = proxy_handler_app
      options = @options
      @__app ||= ::Rack::Builder.new do
        use Rack::GetOnlyCache if options[:enable_cache]
        run ::Rack::Cascade.new([stub_handler, proxy_handler])
      end
    end
    def stub_handler_app
      @_stub_handler_app ||= StubHandler.new
    end
    def proxy_handler_app
      @_proxy_handler_app ||= ProxyHandler.new
    end
  end
end
