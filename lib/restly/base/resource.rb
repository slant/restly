module Restly::Base::Resource
  extend ActiveSupport::Autoload

  autoload :Finders
  autoload :BatchActions
  autoload :Specification

  include Restly::Base::GenericMethods
  include Finders
  include BatchActions

  delegate :first, :last, to: :all

  def resource
    self
  end

end