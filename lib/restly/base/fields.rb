module Restly::Base::Fields
  extend ActiveSupport::Concern

  included do
    extend  ClassMethods

    class_attribute :fields
    self.fields = FieldSet.new(self)
    field :id

    inherited do
      self.fields = fields.dup
    end

  end

  module ClassMethods

    private

    def field(attr)
      if attr.is_a?(Symbol) || attr.is_a?(String)
        define_attribute_method attr unless instance_method_already_implemented? attr
        self.fields += [attr]
      else
        raise Restly::Error::InvalidField, "field must be a symbol or string."
      end
    end

    def exclude_field(name)
      self.fields -= [name]
    end

  end

  class FieldSet < Set

    attr_reader :owner

    def initialize(owner, fields=[])
      @owner = owner
      super(fields)

      self.each { |value| owner.send(:define_attribute_method, value) unless owner.send(:instance_method_already_implemented?, value.to_sym) }
    end

    def include?(value)
      super(value.to_sym) || super(value.to_s)
    end

    def <<(value)
      owner.send(:define_attribute_method, value) unless owner.send(:instance_method_already_implemented?, value.to_sym)
      super(value.to_sym)
    end

    def +(other_array)
      other_array.map!(&:to_sym)
      other_array.each { |value| owner.send(:define_attribute_method, value) unless owner.send(:instance_method_already_implemented?, value.to_sym) }
      super(other_array)
    end

    def -(other_array)
      other_array.map!(&:to_sym)
      other_array.each { |value| owner.send(:define_attribute_method, value) if owner.send(:instance_method_already_implemented?, value.to_sym) }
      super(other_array)
    end

  end

end