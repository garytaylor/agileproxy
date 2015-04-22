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
  gem.name          = RUBY_PLATFORM =~ /java/ ? 'agile-proxy-jruby' : 'agile-proxy'
  gem.require_paths = ['lib']
  gem.version       = AgileProxy::VERSION
  if RUBY_PLATFORM =~ /java/
    gem.platform = 'jruby'
  end

  gem.add_development_dependency 'rake', '~> 0'
  gem.add_development_dependency 'rspec', '~> 3.1', '>= 3.1.0'
  gem.add_development_dependency 'rspec-mocks', '~> 3.1', '>= 3.1.3'
  gem.add_development_dependency 'faraday', '~> 0.9', '>= 0.9.0'
  gem.add_development_dependency 'poltergeist', '~> 1.5', '>= 1.5.1'
  gem.add_development_dependency 'selenium-webdriver', '~> 2.43', '>= 2.43.0'
  gem.add_development_dependency 'guard', '~> 2.6', '>= 2.6.1'
  gem.add_development_dependency 'rb-inotify', '~> 0.9', '>= 0.9.5'
  gem.add_development_dependency 'cucumber', '~> 1.3', '>= 1.3.17'
  gem.add_development_dependency 'rest-client', '~> 1.7', '>= 1.7.2'
  gem.add_development_dependency 'require_all', '~> 1.3', '>= 1.3.2'
  gem.add_development_dependency 'faker', '~> 1.2', '>= 1.2.0'
  gem.add_development_dependency 'yard', '~> 0.8', '>= 0.8'
  gem.add_development_dependency 'simplecov', '~> 0.9', '>= 0.9.1'
  gem.add_development_dependency 'travis', '~> 1.7', '>= 1.7.5'
  gem.add_runtime_dependency 'eventmachine', '~> 1.0', '>= 1.0.3'
  gem.add_runtime_dependency 'em-synchrony', '~> 1.0', '>= 1.0.3'
  gem.add_runtime_dependency 'em-http-request', '~> 1.1', '>= 1.1.2'
  gem.add_runtime_dependency 'grape', '~> 0.10', '>= 0.10.1'
  gem.add_runtime_dependency 'activerecord', '~> 4.2', '>= 4.2.0'
  if RUBY_PLATFORM =~ /java/
    #JVM Only
    gem.add_runtime_dependency 'activerecord-jdbc-adapter'
    gem.add_runtime_dependency 'activerecord-jdbcsqlite3-adapter'
  else
    #Non JVM
    gem.add_runtime_dependency 'sqlite3', '~> 1.3', '>= 1.3.10'
  end



  gem.add_runtime_dependency 'grape-kaminari', '~> 0.1', '>= 0.1.7'
  gem.add_runtime_dependency 'shoulda-matchers', '2.8.0.rc2'
  gem.add_runtime_dependency 'flavour_saver', '~> 0.3', '>= 0.3.4'
  gem.add_runtime_dependency 'thor', '~> 0.19', '>= 0.19.1'
  gem.add_runtime_dependency 'goliath', '~> 1.0', '>= 1.0.4'
  gem.add_runtime_dependency 'rack-cache', '~> 1.2', '>= 1.2'
  gem.add_runtime_dependency 'goliath-proxy', '~> 0.0', '>= 0.0.1'

end
