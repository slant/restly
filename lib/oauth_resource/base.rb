module OauthResource
  class Base
    extend ActiveSupport::Autoload
    include ActiveModel::Serialization

    autoload :Resource
    autoload :Queries
    autoload :Collection
    autoload :Instance
    autoload :Pagination

    autoload :ObjectMethods
    autoload :Error

    include Resource
    include Queries
    include Relationships
    include Pagination

    ActiveSupport.run_load_hooks(:oauth_resource, self)

  end
end