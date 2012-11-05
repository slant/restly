require 'rubygems'
require 'bundler/setup'

require 'active_support/all'
require 'active_model'
require 'rspec'
require 'rspec/autorun'
require 'restly'
require 'pry'
require 'configuration_setup'

RSpec.configure do |conf|
  include OAuth2
end