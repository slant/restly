require "includes/class"
require "oauth_resource/version"
require "oauth2"
require 'oauth/access_token'

module OauthResource
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :AuthProxy
  autoload :Configuration
  autoload :ControllerMethods
  autoload :Relationships
  autoload :Error

end