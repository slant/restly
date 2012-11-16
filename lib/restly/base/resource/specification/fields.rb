class Restly::Base::Resource::Specification::Fields < Restly::Proxies::Base

  attr_reader :spec

  def initialize(spec)
    @spec = spec
    @removed = Set.new
    @added = Set.new
    super Restly::Base::Fields::FieldSet.new
  end

  def -(field)
    @removed << field
    super
  end

  def +(field)
    @added << field
    super
  end

  private

  def method_missing(m, *args, &block)
    reload_specification! unless super.present?
    if (value = super).is_a? self.class
      __setobj__ value
      self
    else
      value
    end
  end

  def reload_specification!
    fields = (spec[:attributes] - @removed.to_a) + @added.to_a
    __setobj__ Restly::Base::Fields::FieldSet.new(fields)
  end

end