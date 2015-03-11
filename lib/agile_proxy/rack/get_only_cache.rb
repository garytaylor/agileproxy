require 'rack-cache'
require 'action_dispatch/http/request'
module AgileProxy
  module Rack
    class GetOnlyCache
      def initialize(app)
        @app = app
      end
      def call(env)
        force_caching(env)
        request = ::ActionDispatch::Request.new(env)
        if request.request_method_symbol == :get
          cache_app.call(env)
        else
          @app.call(env)
        end
      end

      private
      def force_caching(env)
        env.delete 'HTTP_PRAGMA' if env['HTTP_PRAGMA'] == 'no-cache'
        env.delete 'HTTP_CACHE_CONTROL' if env['HTTP_CACHE_CONTROL'] == 'no-cache'
      end
      def cache_app
        @cache_app ||= ::Rack::Cache.new(@app)
      end

    end
  end
end