module Restly::Proxies
  extend ActiveSupport::Autoload

  autoload :Authorization
  autoload :WithParams
  autoload :WithPath
  autoload :Base

  module Associations
    extend ActiveSupport::Autoload

    autoload :Collection
    autoload :Instance

  end

end