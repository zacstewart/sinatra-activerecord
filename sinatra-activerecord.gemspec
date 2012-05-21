# encoding:utf-8

Gem::Specification.new do |gem|
  gem.name         = 'sinatra-activerecord'
  gem.version      = '0.1.3'
  gem.date         = '2009-09-21'

  gem.description  = "Extends Sinatra with ActiveRecord helpers."
  gem.summary      = gem.description
  gem.homepage     = "http://github.com/janko-m/sinatra-activerecord"

  gem.author       = "Janko Marohnić"
  gem.email        = "janko.marohnic@gmail.com"

  gem.license      = "MIT"

  gem.files        = `git ls-files`.split($\)
  gem.require_path = "lib"
  gem.test_files   = gem.files.grep(%r{^(test|spec|features)/})

  gem.add_dependency 'sinatra', '>= 0.9.4'
end
