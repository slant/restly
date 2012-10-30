class Restly::Associations::HasOne < Restly::Associations::Base

  attr_reader :joiner

  def initialize(owner, name, options={})
    @joiner = options.delete(:through)
    super
  end

  def collection?
    true
  end

end