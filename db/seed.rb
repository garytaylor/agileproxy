require 'agile_proxy/model/user'
require 'agile_proxy/model/application'
module AgileProxy
  class Seed
    class << self
      def load_seed
        create_default_user
        create_default_application
      end

      private

      def create_default_user
        User.create name: 'public', email: 'public@agileproxy.com', id: 1 if (User.where(name: 'public').count == 0)
      end

      def create_default_application
        Application.create user_id: public_user.id, name: 'Default Application', username: nil, password: nil, id: 1 if (Application.where(name: 'Default Application').count == 0)
      end

      def public_user
        User.where(name: 'public').first
      end
    end
  end
end