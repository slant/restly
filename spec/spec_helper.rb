require 'rubygems'
require 'bundler/setup'

require 'active_support/all'
require 'active_model'
require 'rspec'
require 'rspec/autorun'
require 'restly'
require 'support/models'
require 'support/routes'

class Post < Restly::Base
  field :body
  field :created_at
  field :updated_at
end

Object.send :define_method, :logger do
  @logger ||= Logger.new(STDOUT)
end

RSpec.configure do |conf|
end