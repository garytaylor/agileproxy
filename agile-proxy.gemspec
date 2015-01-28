# -*- encoding: utf-8 -*-
require File.expand_path('../lib/agile_proxy/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Gary Taylor']
  gem.email         = ['gary.taylor@hismessages.com']
  gem.description   = 'An agile, programmable, controllable proxy server for use standalone or as part of an integration test suite with clients for many languages'
  gem.summary       = 'An agile, programmable, controllable flexible proxy server for development or test use'
  gem.homepage      = 'https://github.com/garytaylor/agileproxy'

  gem.files         = `git ls-files`.split($\).concat(Dir.glob 'assets/ui/bower_components/**/*')
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'agile-proxy'
  gem.require_paths = ['lib']
  gem.version       = AgileProxy::VERSION

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '~> 3.1.0'
  gem.add_development_dependency 'rspec-mocks', '~> 3.1.3'
  gem.add_development_dependency 'faraday', '~> 0.9.0'
  gem.add_development_dependency 'poltergeist', '~> 1.5.1'
  gem.add_development_dependency 'selenium-webdriver', '~> 2.43.0'
  gem.add_development_dependency 'rack', '~> 1.6.0'
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
  gem.add_runtime_dependency 'eventmachine', '~> 1.0.3'
  gem.add_runtime_dependency 'em-synchrony', '~> 1.0.3'
  gem.add_runtime_dependency 'em-http-request', '~> 1.1.2'
  gem.add_runtime_dependency 'eventmachine_httpserver', '~> 0.2.1'
  gem.add_runtime_dependency 'http_parser.rb', '~> 0.6.0'
  gem.add_runtime_dependency 'multi_json'
  gem.add_runtime_dependency 'thin', '~> 1.6.2'
  gem.add_runtime_dependency 'grape', '~> 0.10.1'
  gem.add_runtime_dependency 'activerecord', '~> 4.2.0'
  gem.add_runtime_dependency 'sqlite3', '~> 1.3.10'
  gem.add_runtime_dependency 'grape-kaminari', '~> 0.1.7'
  gem.add_runtime_dependency 'shoulda-matchers', '2.8.0.rc2'
  gem.add_runtime_dependency 'flavour_saver'
  gem.add_runtime_dependency 'thor'
  gem.add_runtime_dependency 'rack-parser', '~> 0.6.1'
end
