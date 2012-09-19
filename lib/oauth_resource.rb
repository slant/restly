require "method_source"
require "oauth_resource/version"
require "oauth2"
require 'oauth/access_token'

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


end