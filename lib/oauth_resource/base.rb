module OauthResource
  class Base
    extend ActiveSupport::Autoload

    autoload :Resource
    autoload :ObjectMethods
    autoload :Instance
    autoload :Collection

    include Resource

  end
end