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
    class RequestSpecRecordings < Grape::API
      include Grape::Kaminari
      helpers do
        # Convenient access to the record specified in the id parameter
        def record
          current_application.recordings.where(request_spec_id: params[:request_spec_id], id: params[:id]).first
        end

        def default_json_spec
          {}
        end
      end

      resource :recordings do
        desc 'List all recordings made for the request spec'
        paginate per_page: 20, max_per_page: 200
        get do
          authenticate!
          scope = current_application.recordings.where({request_spec_id: params[:request_spec_id]})
          { recordings: paginate(scope).as_json(default_json_spec), total: scope.count }
        end
        desc 'Delete all recordings for the application'
        delete do
          authenticate!
          scope = current_application.recordings
          scope.destroy_all request_spec_id: params[:request_spec_id]
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
