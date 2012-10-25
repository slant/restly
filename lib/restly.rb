require "colorize"
require "active_support"
require "restly/version"
require "oauth2"

module Restly
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :BaseProxy
  autoload :Proxies
  autoload :Configuration
  autoload :Collection
  autoload :ControllerMethods
  autoload :Associations
  autoload :NestedAttributes
  autoload :Error
  autoload :Connection
  autoload :Middleware
  autoload :ThreadLocal
  autoload :Client
  autoload :ConcernedInheritance

end

require 'restly/railtie' if Object.const_defined?('Rails')