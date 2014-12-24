require 'rest_client'
module AgileProxy
  module Test
    module Integration
      # A helper for 'request spec' integration tests
      module RequestSpecHelper
        def load_small_set_of_request_specs(options = {})
          let(:recordings_resource) { RestClient::Resource.new "http://localhost:#{api_port}/api/v1/users/1/applications/#{@recording_application_id}/recordings", headers: { content_type: 'application/json' } }
          before :context do

            def configure_applications
              application_resource.delete  # Delete all applications
              @non_recording_application_id = JSON.parse(application_resource.post user_id: 1, name: 'Non recording app', username: 'anonymous', password: 'password')['id']
              @recording_application_id = JSON.parse(application_resource.post user_id: 1, name: 'Recording app', username: 'recording', password: 'password', record_requests: true)['id']
              @direct_application_id = JSON.parse(application_resource.post user_id: 1, name: 'Direct app', username: nil, password: nil, record_requests: false)['id']
            end

            def application_resource
              @__application_resource ||= RestClient::Resource.new "http://localhost:#{api_port}/api/v1/users/1/applications", headers: { content_type: 'application/json' }
            end

            def create_request_spec(attrs)
              non_recording_resource.post ActiveSupport::JSON.encode attrs
              recording_resource.post ActiveSupport::JSON.encode attrs
              direct_resource.post ActiveSupport::JSON.encode attrs
            end

            def non_recording_resource
              @__non_recording_resource ||= RestClient::Resource.new "http://localhost:#{api_port}/api/v1/users/1/applications/#{@non_recording_application_id}/request_specs", headers: { content_type: 'application/json' }
            end

            def recording_resource
              @__recording_resource ||= RestClient::Resource.new "http://localhost:#{api_port}/api/v1/users/1/applications/#{@recording_application_id}/request_specs", headers: { content_type: 'application/json' }
            end

            def direct_resource
              @__direct_resource ||= RestClient::Resource.new "http://localhost:#{api_port}/api/v1/users/1/applications/#{@direct_application_id}/request_specs", headers: { content_type: 'application/json' }
            end

            # Delete all first
            configure_applications
            # Now, add some stubs via the REST interface
            [@http_url, @https_url, @http_url_no_proxy, @https_url_no_proxy].each do |url|
              create_request_spec url: "#{url}/index.html", response: { content_type: 'text/html', content: '<html><body>This Is An Older Mock</body></html>' } #This is intentional - the system should always use the latest
              create_request_spec url: "#{url}/index.html", response: { content_type: 'text/html', content: '<html><body>Mocked Content</body></html>' }
              create_request_spec url: "#{url}/api/forums", response: { content_type: 'application/json', content: JSON.pretty_generate(forums: [], total: 0) }
              create_request_spec url: "#{url}/api/forums", http_method: 'POST', response: { content_type: 'application/json', content: '{"created": true}' }
              create_request_spec url: "#{url}/api/forums/:forum_id/:post_id", response: { content_type: 'text/html', content: '<html><body><h1>Sorted By: {{sort}}</h1><h2>{{forum_id}}</h2><h3>{{post_id}}</h3></body></html>', is_template: true }
              create_request_spec url: "#{url}/api/forums/:forum_id/:post_id", http_method: 'PUT', response: { content_type: 'application/json', content: '{"updated": true}' }
              create_request_spec url: "#{url}/api/forums/:forum_id/:post_id", http_method: 'DELETE', response: { content_type: 'application/json', content: '{"deleted": true}' }
              create_request_spec url: "#{url}/api/forums/:forum_id/:post_id", conditions: '{"post_id": "special"}', response: { content_type: 'text/html', content: '<html><body><h1>Sorted By: {{sort}}</h1><h2>{{forum_id}}</h2><h3>{{post_id}}</h3><p>This is a special response</p></body></html>', is_template: true }
              create_request_spec url: "#{url}/api/forums/:forum_id/:post_id", conditions: '{"post_id": "special", "sort": "eversospecial"}', response: { content_type: 'text/html', content: '<html><body><h1>Sorted By: {{sort}}</h1><h2>{{forum_id}}</h2><h3>{{post_id}}</h3><p>This is an ever so special response</p></body></html>', is_template: true }
              create_request_spec url: "#{url}/api/forums/:forum_id", http_method: 'POST',response: { content_type: 'text/html', content: '<html><body><h1></h1><h2>WRONG RESULT</h2><h3>{{forum_id}}</h3><p>This is an incorrect result probably because the conditions are being ignored ?</p></body></html>'}
              create_request_spec url: "#{url}/api/forums/:forum_id", http_method: 'POST', conditions: '{"posted_var":"special_value"}', response: { content_type: 'text/html', content: '<html><body><h1></h1><h2>{{posted_var}}</h2><h3>{{forum_id}}</h3><p>This should get data from the POSTed data</p></body></html>', is_template: true }
              create_request_spec url: "#{url}/api/forums/:forum_id/posts", response: { content_type: 'application/json', content: JSON.pretty_generate(posts: [
                   { forum_id: '{{forum_id}}', subject: 'My first post' },
                   { forum_id: '{{forum_id}}', subject: 'My second post' },
                   { forum_id: '{{forum_id}}', subject: 'My third post' }
               ], total: 3), is_template: true }
            end
          end
          before :each do
            recordings_resource.delete if options.key?(:recording) && options[:recording]
          end
        end
      end
    end
  end
end
