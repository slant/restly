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
require 'restly/notifications'

class Object

  @@__method_calls ||= {}

  def current_method(index=0)
    /`(?<curr_method>.*?)'/ =~ caller[index]
    curr_method
  end

  def method_called(enum, *args)
    count = enum.count
    method = Digest::MD5.hexdigest( current_method(1) + args.to_sentence )

    @@__method_calls.delete_if { |k, v| v[:timestamp] < Time.now - 10 }
    @@__method_calls[method.to_sym] ||= {}
    @@__method_calls[method.to_sym][:count] ||= 0
    @@__method_calls[method.to_sym][:count] += 1
    @@__method_calls[method.to_sym][:timestamp] = Time.now

    @@__method_calls[method.to_sym][:count] >= count
  end

end