module AgileProxy
  module Test
    module Api
      # A common helper for all API unit tests
      module Common
        def self.included(base)
          base.instance_eval do
            before :each do
              setup_active_record_environment!
              def app
                AgileProxy::Api::Root
              end
            end
          end
        end

        def current_user
          @__current_user ||= double('AgileProxy::User', id: 1, name: 'Test User')
        end

        def current_application
          @__current_application ||= double('AgileProxy::Application', name: 'Default Application', id: 1)
        end

        def setup_active_record_environment!
          allow(AgileProxy::User).to receive(:first).and_return current_user
        end
      end
    end
  end
end
