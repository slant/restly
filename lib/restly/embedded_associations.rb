module Restly::EmbeddedAssociations
  extend ActiveSupport::Autoload
  extend ActiveSupport::Concern

  autoload :EmbeddedIn
  autoload :EmbedsMany
  autoload :EmbedsOne
  autoload :ClassMethods
  autoload :Base

end