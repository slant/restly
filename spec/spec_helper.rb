require 'rubygems'
require 'bundler/setup'

require 'active_support/all'
require 'active_model'
require 'rspec'
require 'rspec/autorun'
require 'restly'
require 'pry'
require 'support/models'
require 'support/routes'

RSpec.configure do |conf|
  include OAuth2
end