# -*- encoding: utf-8 -*-
require File.expand_path('../lib/agile_proxy/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Gary Taylor']
  gem.email         = ['gary.taylor@hismessages.com']
  gem.description   = 'An agile, programmable, controllable proxy server for use standalone or as part of an integration test suite with clients for many languages'
  gem.summary       = 'An agile, programmable, controllable flexible proxy server for development or test use'
  gem.homepage      = 'https://github.com/garytaylor/agileproxy'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'agile-proxy'
  gem.require_paths = ['lib']
  gem.version       = AgileProxy::VERSION

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rspec-mocks'
  gem.add_development_dependency 'faraday'
  gem.add_development_dependency 'poltergeist'
  gem.add_development_dependency 'selenium-webdriver'
  gem.add_development_dependency 'rack'
  gem.add_development_dependency 'guard'
  gem.add_development_dependency 'rb-inotify'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'cucumber'
  gem.add_development_dependency 'airborne'
  gem.add_development_dependency 'rest-client'
  gem.add_development_dependency 'require_all'
  gem.add_development_dependency 'faker'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'simplecov'
  gem.add_runtime_dependency 'eventmachine'
  gem.add_runtime_dependency 'em-synchrony'
  gem.add_runtime_dependency 'em-http-request'
  gem.add_runtime_dependency 'eventmachine_httpserver'
  gem.add_runtime_dependency 'http_parser.rb', '~> 0.6.0'
  gem.add_runtime_dependency 'multi_json'
  gem.add_runtime_dependency 'thin', '1.6.2'
  gem.add_runtime_dependency 'grape'
  gem.add_runtime_dependency 'activerecord'
  gem.add_runtime_dependency 'sqlite3'
  gem.add_runtime_dependency 'grape-kaminari'
  gem.add_runtime_dependency 'shoulda-matchers'
  gem.add_runtime_dependency 'flavour_saver'
  gem.add_runtime_dependency 'thor'
  gem.add_runtime_dependency 'rack-parser'
end
