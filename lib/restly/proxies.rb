module Restly::Proxies
  extend ActiveSupport::Autoload

  autoload :Auth
  autoload :AssociatedInstance
  autoload :AssociatedCollection
  autoload :Params
  autoload :Base

  module Associations
    extend ActiveSupport::Autoload

    autoload :Collection
    autoload :Instance

  end

end