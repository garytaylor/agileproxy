require 'uri'
require 'eventmachine'
require 'http/parser'
require 'em-http'
require 'evma_httpserver'
require 'em-synchrony'
require 'stringio'
require 'rack'

module AgileProxy
  #
  # = The Proxy Connection
  #
  # This class is the event machine connection used by the proxy.  Every request creates a new instance of this
  class ProxyConnection < EventMachine::Connection
    attr_accessor :handler
    def post_init
      @parser = Http::Parser.new(self)
    end

    def receive_data(data)
      @parser << data
    end

    def on_message_begin
      @headers = nil
      @body = ''
    end

    def on_headers_complete(headers)
      @headers = headers
    end

    def on_body(chunk)
      @body << chunk
    end

    def on_message_complete
      if @parser.http_method == 'CONNECT'
        restart_with_ssl(@parser.request_url)
      else
        if @ssl
          uri = URI.parse(@parser.request_url)
          @url = "https://#{@ssl}#{[uri.path, uri.query].compact.join('?')}"
        else
          @url = @parser.request_url
        end
        handle_request
      end
    end

    protected

    def restart_with_ssl(url)
      @ssl = url
      @parser = Http::Parser.new(self)
      @original_headers = @headers.clone
      send_data("HTTP/1.0 200 Connection established\r\nProxy-agent: Http-Flexible-Proxy/0.0.0\r\n\r\n")
      start_tls(
        private_key_file: File.expand_path('../mitm.key', __FILE__),
        cert_chain_file: File.expand_path('../mitm.crt', __FILE__)
      )
    end

    def handle_request
      EM.synchrony do
        request = ActionDispatch::Request.new(env)
        request.params  # This will populate action_dispatch.request.parameters
        handler.call(env).tap do |response|
          send_response(response)
        end
      end
    end

    private

    def env
      return @__env if @__env
      fake_input_buffer = StringIO.new(@body)
      fake_error_buffer = StringIO.new
      url_parsed = URI.parse(@url)
      @__env = {
        'rack.input' => Rack::Lint::InputWrapper.new(fake_input_buffer),
        'rack.errors' => Rack::Lint::ErrorWrapper.new(fake_error_buffer),
        'REQUEST_METHOD' => @parser.http_method,
        'REQUEST_PATH' => url_parsed.path,
        'PATH_INFO' => url_parsed.path,
        'QUERY_STRING' => url_parsed.query || '',
        'REQUEST_URI' => url_parsed.path + (url_parsed.query || ''),
        'rack.url_scheme' => url_parsed.scheme,
        'CONTENT_LENGTH' => @body.length,
        'SERVER_NAME' => url_parsed.host,
        'SERVER_PORT' => url_parsed.port

      }
      @headers.merge(@original_headers || {}).each do |name, value|
        converted_name = "HTTP_#{name.gsub(/-/, '_').upcase}"
        @__env[converted_name] = value
      end
      @__env['CONTENT_TYPE'] = @__env.delete('HTTP_CONTENT_TYPE') if @__env.key?('HTTP_CONTENT_TYPE')
      @__env['CONTENT_LENGTH'] = @__env.delete('HTTP_CONTENT_LENGTH') if @__env.key?('HTTP_CONTENT_LENGTH')
      @__env
    end

    def send_response(response)
      res = EM::DelegatedHttpResponse.new(self)
      res.status = response[0]
      res.headers = response[1]
      res.content = response[2]
      res.send_response
    end
  end
end
