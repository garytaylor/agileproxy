require_relative 'request_specs'
require_relative 'applications'
require_relative 'recordings'
module AgileProxy
  module Api
    #
    # = The API Root
    #
    # This is the root of the entire API for use with REST.  It will not be accessed directly
    #
    class Root < Grape::API
      version 'v1', vendor: 'agile-proxy'
      format :json
      helpers do
        # Provides easy access to the current user.
        # As we are currently only single user, then we just return the first user
        def current_user
          ::AgileProxy::User.first
        end
        # Secured methods must call this first
        def authenticate!
          # Do nothing yet
        end
        # Provides easy access to the current application whether
        # specified in the URL or not (defaults to the first if not)
        def current_application
          fail 'Application ID is missing' unless params.key?(:application_id)
          applications = current_user.applications
          applications.where(id: params[:application_id]).first
        end
      end
      namespace 'users/:user_id' do
        mount Api::Applications
        namespace '/applications/:application_id' do
          mount Api::Recordings
          mount Api::RequestSpecs
        end
      end
    end
  end
end
