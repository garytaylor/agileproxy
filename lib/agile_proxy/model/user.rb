require_relative 'application'
require 'active_record'
module AgileProxy
  #
  # = An API User
  #
  # The API access to the system is multi user in that each user
  # can have many applications and each application can have many stubs etc...
  #
  # This class is responsible for :-
  # 1. Retrieving users from storage
  # 2. Persisting users to storage
  # 3. Providing a list of applications that the user owns
  class User < ActiveRecord::Base
    has_many :applications
  end
end
