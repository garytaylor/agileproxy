module AgileProxy
  module Api
    #
    # = A grape API for recordings
    #
    # If the application is set to allow recordings, each HTTP request and response passing
    # through the proxy server will be recorded.
    #
    # This API allows access to those recordings via REST
    #
    class Recordings < Grape::API
      include Grape::Kaminari
      helpers do
        # Convenient access to the record specified in the id parameter
        def record
          current_application.recordings.where(id: params[:id]).first
        end

        def default_json_spec
          {}
        end
      end

      resource :recordings do
        desc 'List all recordings made for the application'
        paginate per_page: 20, max_per_page: 200
        get do
          authenticate!
          scope = current_application.recordings
          { recordings: paginate(scope).as_json(default_json_spec), total: scope.count }
        end
        desc 'Delete all rcordings for the application'
        delete do
          authenticate!
          scope = current_application.recordings
          scope.destroy_all
          { recordings: [], total: 0 }
        end
        desc 'Get a recording by id'
        get ':id' do
          authenticate!
          record.as_json(default_json_spec)
        end
        delete ':id' do
          authenticate!
          record.tap(&:destroy).as_json(default_json_spec)
        end

      end
    end
  end
end
