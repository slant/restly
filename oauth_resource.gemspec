# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oauth_resource/version'

Gem::Specification.new do |gem|
  gem.name          = "oauth_resource"
  gem.version       = OauthResource::VERSION
  gem.authors       = ["Jason Waldrip"]
  gem.email         = ["jason@waldrip.net"]
  gem.description   = %q{ Allows your app to authenticate a resource with oauth}
  gem.summary       = %q{ Allows your app to authenticate a resource with oauth}
  gem.homepage      = "http://github.com/jwaldrip/oauth_resource"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency "oauth2"
  gem.add_dependency "activesupport"

end
