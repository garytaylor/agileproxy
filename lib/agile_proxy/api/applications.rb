module AgileProxy
  module Api
    #
    # = A grape api for applications
    #
    # An application is a central resource for the proxy, it is the 'application under test or development'
    #
    # The proxy server can handle multiple applications by assigning each one a different username and password
    # that is used when connecting to the proxy.
    # Each application can have its own set of stubs, can be set to record or not and much much more.
    class Applications < Grape::API
      include Grape::Kaminari
      helpers do
        # We only allow selected parameters through - spec and note
        def permitted_params
          @permitted_params ||= declared(
              params,
              { include_missing: false },
              [:username, :password, :name, :record_requests]
          )
        end

        # Convenient access to the record specified in the id parameter
        def record
          current_user.applications.where(id: params[:id]).first
        end

        # Convenient access to the record parameters from a POST or a PUT, only permitted will be returned
        def record_params
          permitted_params.with_indifferent_access
        end

        def default_json_spec
          {}
        end

      end

      resource :applications do
        desc 'List all applications for the user'
        paginate per_page: 20, max_per_page: 200
        get do
          authenticate!
          scope = current_user.applications
          { applications: paginate(scope).as_json(default_json_spec), total: scope.count }
        end
        desc 'Delete all applications for the user'
        delete do
          authenticate!
          scope = current_user.applications
          scope.destroy_all
          { applications: [], total: 0 }
        end
        desc 'Create a new application for the user'
        post do
          authenticate!
          current_user.applications.create!(record_params.merge user_id: current_user.id).as_json(default_json_spec)
        end
        desc 'Get an application by id'
        get ':id' do
          authenticate!
          record.as_json(default_json_spec)
        end
        delete ':id' do
          authenticate!
          record.tap(&:destroy).as_json(default_json_spec)
        end
        desc 'Update a request application'
        put ':id' do
          authenticate!
          record.tap { |r| r.update_attributes(record_params) }.as_json(default_json_spec)
        end

      end
    end
  end
end
