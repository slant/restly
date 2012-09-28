require "method_source"
require "oauth_resource/version"
require "oauth2"

module OauthResource
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :BaseProxy
  autoload :Proxies
  autoload :Configuration
  autoload :Collection
  autoload :ControllerMethods
  autoload :Relationships
  autoload :Error
  autoload :Connection
  autoload :Middleware

end

require 'oauth_resource/railtie' if Object.const_defined?('Rails')