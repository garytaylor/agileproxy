require_relative 'application'
module AgileProxy
  #
  # = The recording model
  #
  # When an application is set to allow recording, every HTTP(s) request/response cycle coming through the proxy
  # will create an instance of this model and persist it to the database.
  #
  # An API is then available to access this data via REST for the UI or test suite etc...
  #
  class Recording < ActiveRecord::Base
    belongs_to :application
    serialize :request_headers, JSON
    serialize :response_headers, JSON
  end
end
