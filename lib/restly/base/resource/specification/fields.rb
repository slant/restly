class Restly::Base::Resource::Specification::Fields < Restly::Proxies::Base

  attr_reader :spec

  def initialize(spec)
    @spec = spec
    @removed = Set.new
    @added = Set.new
    super Restly::Base::Fields::FieldSet.new(spec.model)
  end

  def - field
    @removed << field
    method_missing __method__, field
  end

  def + field
    @added << field
    method_missing __method__, field
  end

  private

  def method_missing(m, *args, &block)
    reload_specification! if !super.present? || m == :inspect
    if (value = super).is_a? self.class
      duplicate = self.dup
      duplicate.__setobj__ super
      duplicate
    else
      value
    end
  end

  def reload_specification!
    from_spec = spec[:attributes] || []
    fields = (from_spec - @removed.to_a) + @added.to_a
    __setobj__ Restly::Base::Fields::FieldSet.new(spec.model, fields)
  end

end