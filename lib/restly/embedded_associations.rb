module Restly::EmbeddedAssociations
  extend ActiveSupport::Autoload

  autoload :EmbeddedIn
  autoload :EmbedsMany
  autoload :EmbedsOne
  autoload :ClassMethods
  autoload :Base

  extend ActiveSupport::Concern

end