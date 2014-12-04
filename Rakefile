#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'active_record'
require_relative 'db/seed'
include ActiveRecord::Tasks
DatabaseTasks.database_configuration = YAML.load_file('config.yml')
DatabaseTasks.db_dir = 'db'
DatabaseTasks.migrations_paths = 'db/migrations'
DatabaseTasks.env = ENV['ENV'] || 'development'
DatabaseTasks.seed_loader = AgileProxy::Seed
ActiveRecord::Base.establish_connection(DatabaseTasks.database_configuration[DatabaseTasks.env])
DatabaseTasks.root = File.dirname(__FILE__)
Rake::Task.define_task(:environment)
# other settings...
load 'active_record/railties/databases.rake'
