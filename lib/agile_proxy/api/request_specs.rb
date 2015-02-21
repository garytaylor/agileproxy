require 'agile_proxy/model/request_spec'
require 'grape-kaminari'
module AgileProxy
  module Api
    #
    # = A grape API for request specifications
    #
    # A 'request specification' is what is known as a 'Stub' in the UI.
    #
    # It defines an input and output spec for a HTTP(s) request.
    #
    # For example, we could say
    # 'When http://www.mybing.com/search.html is requested with some specific query parameters, then respond with this'
    #
    # This API allows full CRUD access to these request specifications, but only those belonging to the logged in user.
    #
    class RequestSpecs < Grape::API
      include Grape::Kaminari
      helpers do
        # We only allow selected parameters through - spec and note
        def permitted_params
          @permitted_params ||= declared(
              params,
              { include_missing: false },
              [:spec, :note, :response, :http_method, :url, :url_type, :conditions, :record_requests]
          )
        end

        # Convenient access to the record specified in the id parameter
        def record
          current_application.request_specs.where(id: params[:id]).first
        end

        # Convenient access to the record parameters from a POST or a PUT, only permitted will be returned
        # Note that for some reason, to do with rack or grape,
        # when we send a large body, the request_spec does not come through
        # so, to work around this, we inject the request spec in afterwards if it is missing.
        def record_params
          p = permitted_params.with_indifferent_access
          p.merge!(user_id: current_user.id, application_id: current_application.id)
          p[:response_attributes] = p.delete(:response) if p.key?(:response)
          p
        end

        def default_json_spec
          { include: { response: { except: [:created_at, :updated_at] } } }
        end

      end
      resource :request_specs do
        desc 'List all request specifications for the application'
        paginate per_page: 50, max_per_page: 200
        get do
          authenticate!
          scope = current_application.request_specs
          { request_specs: paginate(scope).as_json(default_json_spec), total: scope.count }
        end
        delete do
          authenticate!
          scope = current_application.request_specs
          scope.destroy_all
          { request_specs: [], total: 0 }
        end
        desc 'Create a new request specification'
        post do
          authenticate!
          current_application.request_specs.create(record_params).as_json(default_json_spec)
        end
        get ':id' do
          authenticate!
          record.as_json(default_json_spec)
        end
        desc 'Update a request specification'
        put ':id' do
          authenticate!
          record.tap { |r| r.update_attributes(record_params) }.as_json(default_json_spec)
        end
        delete ':id' do
          authenticate!
          record.tap(&:destroy).as_json(default_json_spec)
        end

      end
    end
  end
end
