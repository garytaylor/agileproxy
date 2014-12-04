require 'agile_proxy/handlers/handler'
require 'eventmachine'
require 'em-synchrony/em-http'

module AgileProxy
  # = The handler used for proxying the request on to the original server
  #
  # This handler is responsible for proxying the request through to the original server and passing back its response
  #
  # It works as a rack end point as usual :-)
  #
  class ProxyHandler
    include Handler

    # The endpoint called by 'rack'
    #
    # Requests the response back from the destination server and passes it back to the client
    #
    # @param env [Hash] The rack environment hash
    # @return [Array] The rack response array (status, headers, body)
    def call(env)
      request = ActionDispatch::Request.new(env)
      method = request.request_method.downcase
      body = request.body.read
      request.body.rewind
      url = request.url
      if handles_request?(request)
        req = EventMachine::HttpRequest.new(request.url,
                                            inactivity_timeout: AgileProxy.config.proxied_request_inactivity_timeout,
                                            connect_timeout: AgileProxy.config.proxied_request_connect_timeout
        )

        req = req.send(method.downcase, build_request_options(request.headers, body))

        if req.error
          return [500, {}, "Request to #{request.url} failed with error: #{req.error}"]
        end

        if req.response
          response = process_response(req)

          unless allowed_response_code?(response[:status])
            AgileProxy.log(:warn, "agile-proxy: Received response status code #{response[:status]} for '#{url}'")
          end

          AgileProxy.log(:info, "agile-proxy: PROXY #{request.request_method} succeeded for '#{request.url}'")
          return [response[:status], response[:headers], response[:content]]
        end
      end
      [404, {}, 'Not proxied']
    end

    private

    def handles_request?(request)
      !disabled_request?(request.url)
    end

    def build_request_options(headers, body)
      headers = Hash[headers.map { |k, v| [k.downcase, v] }]
      headers.delete('accept-encoding')

      req_opts = {
        redirects: 0,
        keepalive: false,
        head: headers,
        ssl: { verify: false }
      }
      req_opts[:body] = body if body
      req_opts
    end

    def process_response(req)
      response = {
        status: req.response_header.status,
        headers: req.response_header.raw,
        content: req.response.force_encoding('BINARY') }
      response[:headers].merge!('Connection' => 'close')
      response[:headers].delete('Transfer-Encoding')
      response
    end

    def disabled_request?(url)
      return false unless AgileProxy.config.non_whitelisted_requests_disabled

      uri = URI(url)
      # In isolated environments, you may want to stop the request from happening
      # or else you get "getaddrinfo: Name or service not known" errors
      blacklisted_path?(uri.path) || !whitelisted_url?(uri)
    end

    def allowed_response_code?(status)
      successful_status?(status)
    end

    def whitelisted_url?(url)
      !AgileProxy.config.whitelist.index do |v|
        v =~ /^#{url.host}(?::#{url.port})?$/
      end.nil?
    end

    def blacklisted_path?(path)
      !AgileProxy.config.path_blacklist.index { |bl| path.include?(bl) }.nil?
    end

    def successful_status?(status)
      (200..299).include?(status) || status == 304
    end
  end
end
