module AgileProxy
  #
  # An instance of this class represents a route within the system.
  #
  class Route
    attr_accessor :request_method, :pattern, :app, :constraints, :name

    PATH_INFO = 'PATH_INFO'.freeze
    ROUTE_PARAMS = 'rack.route_params'.freeze
    QUERY_STRING = 'QUERY_STRING'.freeze
    FORM_HASH = 'rack.request.form_hash'.freeze
    REQUEST_METHOD = 'REQUEST_METHOD'.freeze
    HEAD = 'HEAD'.freeze
    GET = 'GET'.freeze
    POST = 'POST'.freeze
    PUT = 'PUT'.freeze
    DELETE = 'DELETE'.freeze

    DEFAULT_WILDCARD_NAME = :paths
    WILDCARD_PATTERN = /\/\*(.*)/.freeze
    NAMED_SEGMENTS_PATTERN = /\/:([^$\/]+)/.freeze
    NAMED_SEGMENTS_REPLACEMENT_PATTERN = /\/:([^$\/]+)/.freeze
    DOT = '.'.freeze

    def initialize(request_method, pattern, app, options = {})
      fail ArgumentError, 'pattern cannot be blank' if pattern.to_s.strip.empty?
      fail ArgumentError, 'app must be callable' unless app.respond_to?(:call)
      @request_method = request_method
      @pattern = pattern
      @app = app
      @constraints = options && options[:constraints]
      @name = options && options[:as]
    end

    def regexp
      @regexp ||= compile
    end

    def compile
      pattern_match = pattern.match(WILDCARD_PATTERN)
      src = if pattern_match
              @wildcard_name = if pattern_match[1].to_s.strip.empty?
                                 DEFAULT_WILDCARD_NAME
                               else
                                 pattern_match[1].to_sym
                               end
              pattern.gsub(WILDCARD_PATTERN, '(?:/(.*)|)')
            else
              pattern_match = pattern.match(NAMED_SEGMENTS_PATTERN)
              p = if pattern_match
                    pattern.gsub(NAMED_SEGMENTS_REPLACEMENT_PATTERN, '/(?<\1>[^.$/]+)')
                  else
                    pattern
                  end
              p + '(?:\.(?<format>.*))?'
            end
      Regexp.new("\\A#{src}\\Z")
    end

    def match(env)
      request_method = env[REQUEST_METHOD]
      request_method = GET if request_method == HEAD
      path = env[PATH_INFO]
      qs = env[QUERY_STRING]
      return nil unless request_method == self.request_method
      fail ArgumentError, 'path is required' if path.to_s.strip.empty?
      path_match = path.match(regexp)
      return unless path_match
      params = if @wildcard_name
                 { @wildcard_name => path_match[1].to_s.split('/') }
               else
                 Hash[path_match.names.map(&:to_sym).zip(path_match.captures)]
               end
      params.merge!(::Rack::Utils.parse_nested_query(qs).symbolize_keys) unless qs.nil? || qs.empty?
      params.merge! env[FORM_HASH] if env.key? FORM_HASH
      params.delete(:format) if params.key?(:format) && params[:format].nil?

      params if meets_constraints(params)
    end

    def meets_constraints(params)
      if constraints
        constraints.each do |param, constraint|
          unless params.symbolize_keys[param.to_sym].to_s.match(constraint)
            return false
          end
        end
      end
      true
    end

    def eql?(other)
      other.is_a?(self.class) &&
        other.request_method == request_method &&
        other.pattern == pattern &&
        other.app == app &&
        other.constraints == constraints
    end

    alias_method :==, :eql?

    def hash
      request_method.hash ^ pattern.hash ^ app.hash ^ constraints.hash
    end
  end
end
