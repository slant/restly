# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'restly/version'

Gem::Specification.new do |gem|
  gem.name          = "restly"
  gem.version       = Restly::VERSION
  gem.authors       = ["Jason Waldrip", "DeLynn Berry", "Ryan Cross", "Mike Zelem"]
  gem.email         = ["jason@waldrip.net", "delynn@gmail.com", "rcross@cylence.com", "mzelem@healthagen.net"]
  gem.description   = %q{ An ODM for a RESTful service }
  gem.summary       = %q{ Restly incorporates a ActiveModel based ODM for your REST based service. Think of Restly as a Re-imagination of Rails' ActiveResource }
  gem.homepage      = "http://github.com/jwaldrip/restly"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency "oauth2", "> 0.6"
  gem.add_dependency "activesupport", "~> 3.2"
  gem.add_dependency "activemodel", "~> 3.2"
  gem.add_dependency "colorize", "~> 0.5.8"

  gem.add_development_dependency "rspec", "~> 2.12"
  gem.add_development_dependency "pry", "~> 9.10"
  gem.add_development_dependency "faraday_simulation", "~> 0.0.2"
  gem.add_development_dependency "faraday_middleware", "~> 0.9"
  gem.add_development_dependency "multi_xml", "~> 0.5"

end
