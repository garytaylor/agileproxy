require 'agile_proxy/model/application'
require 'agile_proxy/model/recording'
require 'rack'
require 'forwardable'
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
      if application.record_requests
        application.recordings.create request_headers: request.headers,
                                      request_body: body,
                                      request_url: request.url,
                                      request_method: request.request_method,
                                      response_headers: rack_response[1],
                                      response_body: rack_response[2],
                                      response_status: rack_response[0],
                                      request_spec_id: env['agile_proxy.request_spec_id']
      end
      rack_response
    end

    private

    def rack_app
      @__app ||= Rack::Builder.new do
        run Rack::Cascade.new([StubHandler.new, ProxyHandler.new])
      end
    end
  end
end
