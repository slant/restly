module OauthResource
  class Base
    # Autoload
    extend ActiveSupport::Autoload
    autoload :Resource
    autoload :Queries
    autoload :Collection
    autoload :Instance
    autoload :Pagination
    autoload :ObjectMethods
    autoload :Error

    # Extensions
    extend ActiveModel::Naming
    extend ActiveModel::Callbacks

    # Includes
    include Resource
    include Queries
    include Relationships
    include Pagination

    ActiveSupport.run_load_hooks(:oauth_resource, self)

  end
end