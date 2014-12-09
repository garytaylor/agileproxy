require_relative 'user'
require_relative 'recording'
module AgileProxy
  #
  # = The Application Model
  #
  # The application model is responsible for storing and retrieving information about the application
  # that the application under test / development is using.
  #
  # This is found using the username and password, therefore, a username and password must be globally unique.
  #
  # The reason for doing it this way is because we can only pass username and password in the URL for the proxy server
  #
  class Application < ActiveRecord::Base
    belongs_to :user
    has_many :request_specs, :dependent => :destroy
    has_many :recordings, :dependent => :delete_all
    validates_uniqueness_of :password, scope: :username
  end
end
