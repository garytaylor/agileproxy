require 'agile_proxy'
require 'thor'
require 'active_record'
require_relative '../../db/seed'

module AgileProxy
  include ActiveRecord::Tasks
  class Cli < Thor
    class << self
      def data_dir_base
        if RUBY_PLATFORM =~ /win32/
          ENV['APPDATA']
        elsif RUBY_PLATFORM =~ /linux/
          ENV['HOME']
        elsif RUBY_PLATFORM =~ /darwin/
          ENV['HOME']
        elsif RUBY_PLATFORM =~ /freebsd/
          ENV['HOME']
        else
          ENV['HOME']
        end
      end

      def data_dir
        if Dir.pwd == File.expand_path('../..', File.dirname(__FILE__))
          Dir.pwd
        else
          File.join data_dir_base, '.agile_proxy'
        end
      end

      def environment
        ENV['AGILE_PROXY_ENV'] || (Dir.pwd == File.expand_path('../..', File.dirname(__FILE__)) ? 'development' : 'production')
      end
    end
    package_name 'Http Flexible Proxy'
    desc 'start PROXY_PORT WEBSERVER_PORT', 'Runs the agile proxy'
    method_options data_dir: data_dir, database_config_file: 'db.yml', env: environment
    def start(proxy_port = nil, server_port = nil, webserver_port = nil)
      ensure_database_config_file_exists database_config_file(options)
      puts "Data dir is #{options.data_dir}, environment is #{options.env}"
      setup_for_migrations(options)
      ::AgileProxy.configure do |config|
        config.proxy_port = proxy_port unless proxy_port.nil?
        config.server_port = server_port unless server_port.nil?
        config.webserver_port = webserver_port unless webserver_port.nil?
        config.environment = options.env
        config.database_config_file = database_config_file(options)
      end
      server = AgileProxy::Server.new
      update_db
      server.start
    end

    private

    def setup_for_migrations(options)
      ActiveRecord::Tasks::DatabaseTasks.db_dir = options.data_dir
      ActiveRecord::Tasks::DatabaseTasks.migrations_paths = [File.expand_path('../../db/migrations', File.dirname(__FILE__))]
      ActiveRecord::Tasks::DatabaseTasks.env = options.env
      ActiveRecord::Tasks::DatabaseTasks.root = File.expand_path('../..', __FILE__)
      ActiveRecord::Migrator.migrations_paths = ActiveRecord::Tasks::DatabaseTasks.migrations_paths
    end
    def run_migrations
      ActiveRecord::Migration.verbose = true
      ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths, nil) do |migration|
        ENV["SCOPE"].blank? || (ENV["SCOPE"] == migration.scope)
      end
    end

    def seed_database
      Seed.load_seed
    end

    def server
      AgileProxy::Server.new
    end

    def update_db
      ActiveRecord::Tasks::DatabaseTasks.create_current
      run_migrations
      seed_database
      # Rake::Task['db:create'].invoke
      # Rake::Task['db:migrate'].invoke


    end

    def ensure_database_config_file_exists(fn)
      return if File.exist? fn
      FileUtils.mkdir_p File.dirname fn
      db = {
          :development => {
              adapter: 'sqlite3',
              database: File.join(File.dirname(fn), 'db', 'development.db')
          },
          :test => {
              adapter: 'sqlite3',
              database: File.join(File.dirname(fn), 'db', 'test.db')
          },
          :production => {
              adapter: 'sqlite3',
              database: File.join(File.dirname(fn), 'db', 'production.db')
          }
      }
      File.open(fn, 'w') {|f| f.write(db.to_yaml) }
    end
    def database_config_file(options)
      if File.exist? options.database_config_file
        options.database_config_file
      else
        File.join(options.data_dir, options.database_config_file)
      end
    end
  end
end
