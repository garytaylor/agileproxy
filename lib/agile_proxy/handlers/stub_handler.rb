require 'agile_proxy/handlers/handler'
require 'agile_proxy/model/request_spec'
require 'agile_proxy/router'
require 'agile_proxy/model/application'
require 'action_dispatch'
require 'base64'
module AgileProxy
  # = The stub handler
  #
  # This class is resonsible for matching incoming requests
  # with a stub (request spec) and if one exists, respond with it
  # rather than the real response from the destination server.
  class StubHandler
    include Handler

    # Called by 'rack' as an endpoint.
    #
    # Fetches a 'short list' of potential matching request specs and builds a routing table to allow
    # a router to do the hard work of parsing parameters, matching them, matching URL's etc...
    #
    # @param env [Hash] The rack environment
    # @return [Array] The rack response [status, headers, body]
    def call(env)
      request = ActionDispatch::Request.new(env)
      username, password = username_password env
      @route_set = ActionDispatch::Routing::RouteSet.new

      my_short_list = short_list(username, password, request.request_method, request.url).all.to_a.reverse
      headers = downcased_headers(env)
      body = request.body.read
      request.body.rewind
      setup_router my_short_list, request, headers, body
      rack_app.call(env)
    end

    private

    def setup_router(my_short_list, request, headers, body)
      me = self
      @route_set.draw do
        route_set_instance = self
        me.instance_eval do
          my_short_list.each(&add_to_router(request, headers, body, route_set_instance))
        end
      end
    end

    def add_to_router(request, headers, body, route_set)
      # This needs a bit of explaining as the router did not quite behave as expected.
      # This proc calls route definition methods such as get, post etc.. with the path and handler
      # the handler being an inline proc.
      # But, we also pass a constraints handler
      # After constraints are handled though, the 'action_dispatch.request.parameters' are deleted
      # from the env, so our handler preserves them in agile_proxy.parameters.
      # A bit weird, but it works reliably.
      proc do |spec|
        path = URI.parse(spec.url).path
        path = '/' if path == ''
        method = spec.http_method.downcase.to_sym
        method = :get if method == :head
        route_spec = {
          path => proc do |router_env|
            AgileProxy.log(:info, "agile-proxy: STUB #{method} for '#{request.url}'")
            router_env['agile_proxy.request_spec'] = spec
            spec.call(HashWithIndifferentAccess.new(router_env['action_dispatch.request.path_parameters'].merge(router_env['action_dispatch.request.query_parameters']).merge(router_env['action_dispatch.request.request_parameters'])), headers, body)
          end
        }
        route_spec[:constraints] = ->(request) {
          ret_value = spec.conditions_json.all? do |k, v|
            request.params.key?(k) && request.params[k] == v
          end
          ret_value
        }
        route_set.send method, route_spec
      end
    end

    def collection(username, password)
      #An empty string and NULL are the same thing here.  The UI has no way of sending NULL when creating an application
      if (username.nil? && password.nil?)
        Application.where('(username = ? OR username IS NULL) AND (password = ? OR password IS NULL)', '', '').first.request_specs
      else
        Application.where(username: username, password: password).first.request_specs
      end
    end

    def short_list(username, password, _method, url)
      parsed_url = URI.parse(url)
      parsed_url.path = ''
      parsed_url.query = nil
      parsed_url.fragment = nil
      # @TODO This is being lazy - the ruby code will do all the finding work.
      # This has to change as we go towards mutli user and larger data sets
      collection(username, password).where('url LIKE ?', "#{parsed_url}%")
    end

    def rack_app
      route_set = @route_set
      text_handler = plain_text_handler
      Rack::Builder.new do
        use ActionDispatch::ParamsParser, Mime::TEXT => text_handler
        use MergePostAndGetParams
        use Rack::ContentLength
        run route_set
      end
    end

    def plain_text_handler
      proc do |raw_post|
        data_as_array = raw_post.split("\n").map do |line|
          arr = line.split('=')
          arr << nil if arr.length == 1
          arr
        end.flatten
        data = Hash[*data_as_array]
        ActionDispatch::Request::Utils.deep_munge(data).with_indifferent_access
      end
    end
  end
  #
  # @private
  # A rack middleware to merge post and get parameters ready for routing
  class MergePostAndGetParams
    def initialize(app)
      @app = app
    end

    def call(env)
      request = ActionDispatch::Request.new(env)
      request.params  #Might seem odd, but action dispatch request is a bit naughty and adds the appropriate
                      # bits to ENV during access to this getter when used for the first time
      env['action_dispatch.request.parameters'].merge!(
          env['action_dispatch.request.request_parameters']
      ) unless request.content_length.zero?
      @app.call(env)
    end
  end
end
module ActionDispatch
  module Routing
    # Extension to action dispatch to ensure all request parameters are collected not just GET
    class RouteSet
      PARAMETERS_KEY = 'action_dispatch.request.parameters'
    end
  end
end
