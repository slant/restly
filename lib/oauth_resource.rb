require "oauth_resource/version"
require "oauth2"
require 'oauth/access_token'

module OauthResource
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :Configuration
  autoload :ControllerMethods
  autoload :Relationships

end