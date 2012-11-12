require "colorize" if defined?(IRB)
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
  autoload :EmbeddedAssociations
  autoload :NestedAttributes
  autoload :Error
  autoload :Connection
  autoload :Middleware
  autoload :ThreadLocal
  autoload :Client
  autoload :ConcernedInheritance

  if defined?(Rails::Console)
    def self.login(username, password, scope = "full")
      Base.current_token = { access_token: Client.new.password.get_token(username, password, scope: scope).token }
    end
  end

end

require 'restly/railtie' if Object.const_defined?('Rails')