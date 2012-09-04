module OauthResource
  class Base
    extend ActiveSupport::Autoload

    autoload :Resource
    autoload :ObjectMethods
    autoload :Instance
    autoload :Collection
    autoload :Error

    include Resource
    include Relationships

  end
end