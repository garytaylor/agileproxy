require_relative 'application'
require_relative 'user'
require_relative 'response'
module AgileProxy
  #
  # = The Request Spec model
  # The request spec is an input/output specification that incoming HTTP(s) requests are matched against.
  #
  # It uses the action dispatch router to do this matching,
  # which is fed data from the database as it's input - i.e. its routing
  # table is generated on the fly.
  #
  # This model is responsible not only for retrieving and persisting these
  # request specifications, but also for creating the response
  #
  class RequestSpec < ActiveRecord::Base
    belongs_to :application
    belongs_to :user
    belongs_to :response, :dependent => :destroy
    accepts_nested_attributes_for :response
    validates_inclusion_of :url_type, in: %w(url regex)
    validates_presence_of :application_id
    def initialize(attrs = {})
      attrs[:http_method] = attrs.delete(:method) if attrs.key?(:method)
      super
    end
    # The conditions are at present, stored as a JSON string.  This is editable as a string in the UI, and therefore
    # accessible using 'conditions' as normal.
    # This method returns a JSON decoded version of this as a HASH
    # @return [Hash] decoded conditions
    def conditions_json
      ActiveSupport::JSON.decode(conditions)
    end
    # This method's output is a 'rack' response, but its input is not.
    # When the router has determined that this request spec is the one that is going to be sent to the client,
    # it will call this method with the request's parameters, headers and body.
    #
    # if no response has been specified, an empty body will be returned,
    # otherwise a 'rack' version of the response is returned
    # @param params [Hash] the request parameters
    # @param headers [Hash] The request headers
    # @param body [String] The request body
    # @return [Array] The rack response
    def call(params, headers, body)
      response.nil? ? [204, { 'Content-Type' => 'text/plain' }, ''] : response.to_rack(params, headers, body)
    end
  end
end
