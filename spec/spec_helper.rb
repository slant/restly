require 'rubygems'
require 'bundler/setup'

require 'active_support/all'
require 'active_model'
require 'rspec'
require 'rspec/autorun'
require 'restly'


Restly::Configuration.load_config(
  {
    site: 'http://fakesi.te',
    client_id: 'default_id',
    client_secret: 'default_secret',
    default_format: 'json',
    cache: false,
    cache_opts: {
      expires_in: 3600
    }
  }
)

Faraday.default_adapter = :test

RSpec.configure do |conf|
  include OAuth2
end