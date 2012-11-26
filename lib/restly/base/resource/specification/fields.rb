class Restly::Base::Resource::Specification::Fields < Restly::Proxies::Base

  attr_reader :spec

  def initialize(spec)
    @spec = spec
    @removed = Set.new
    @added = Set.new
    super Restly::Base::Fields::FieldSet.new(spec.model)
  end

  def - field
    @removed += field
    replace(__getobj__.send __method__, field)
  end

  def + field
    @added += field
    replace(__getobj__.send __method__, field)
  end

  private

  def method_missing(m, *args, &block)
    reload_specification! if !super.present? || m == :inspect
    if (value = super).is_a? self.class
      replace(super)
    else
      value
    end
  end

  def replace(object)
    duplicate = self.dup
    duplicate.__setobj__ object
    duplicate
  end

  def reload_specification!
    from_spec = spec[:attributes] || []
    fields = (from_spec.map(&:to_sym) - @removed.map(&:to_sym)) + @added.map(&:to_sym)
    __setobj__ Restly::Base::Fields::FieldSet.new(spec.model, fields)
  end

end