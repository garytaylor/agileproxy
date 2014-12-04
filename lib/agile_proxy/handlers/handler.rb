require 'rack'
module AgileProxy
  # A mixin that all handlers must include
  module Handler
    ##
    #
    # Handles an incoming rack request and returns a rack response.
    #
    # This method accepts rack request parameters and must return
    # a rack response array containing [status, headers, content]
    # , or [404, {}, ''] if the request cannot be fulfilled.
    #
    # @param  _env [Hash] The rack environment
    # @return [Array]               An array of [status, headers, content]
    #                               Returns status of 404 if the request cannot be fulfilled.
    def call(_env)
      [500, {}, 'The handler has not overridden the handle_request method!']
    end

    private

    def username_password(env)
      Base64.decode64(env['HTTP_PROXY_AUTHORIZATION'].sub(/^Basic /, '')).split(':') if proxy_auth? env
    end

    def proxy_auth?(env)
      env.key?('HTTP_PROXY_AUTHORIZATION') && env['HTTP_PROXY_AUTHORIZATION'] =~ /^Basic /
    end

    def downcase_header_name(name)
      name.split(/_/).drop(1).map { |word| word.downcase.capitalize }.join('-')
    end

    def downcased_headers(env)
      headers = {}
      env.each do |name, value|
        next unless name =~ /^HTTP_/
        headers[downcase_header_name(name)] = value
      end
      headers
    end
  end
end
