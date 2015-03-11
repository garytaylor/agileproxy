module AgileProxy
  module Test
    # Common helpers for the test suite
    module Common
      def to_rack_env(opts = {})
        fake_input_buffer = StringIO.new(opts[:body] || '')
        fake_error_buffer = StringIO.new
        url_parsed = URI.parse(opts[:url])
        env = {
          'rack.input' => ::Rack::Lint::InputWrapper.new(fake_input_buffer),
          'rack.errors' => ::Rack::Lint::ErrorWrapper.new(fake_error_buffer),
          'REQUEST_METHOD' => (opts[:method] || 'GET').upcase,
          'REQUEST_PATH' => url_parsed.path,
          'PATH_INFO' => url_parsed.path,
          'QUERY_STRING' => url_parsed.query || '',
          'REQUEST_URI' => url_parsed.path + (url_parsed.query.nil? ? '' : url_parsed.query),
          'rack.url_scheme' => url_parsed.scheme,
          'CONTENT_LENGTH' => (opts[:body] || '').length,
          'SERVER_NAME' => url_parsed.host,
          'SERVER_PORT' => url_parsed.port
        }
        (opts[:headers] || {}).each do |name, value|
          converted_name = 'HTTP_' + (name.gsub(/-/, '_').upcase)
          env[converted_name] = value
        end
        env['CONTENT_TYPE'] = env.delete('HTTP_CONTENT_TYPE') if env.key?('HTTP_CONTENT_TYPE')
        env['CONTENT_LENGTH'] = env.delete('HTTP_CONTENT_LENGTH') if env.key?('HTTP_CONTENT_LENGTH')
        env
      end
    end
  end
end
