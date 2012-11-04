module Restly::Base::Fields
  extend ActiveSupport::Concern

  included do
    extend  SharedMethods
    include SharedMethods
    extend  ClassMethods

    class_attribute :fields
    self.fields = FieldSet.new
    field :id

    inherited do
      self.fields = fields.dup
    end

  end

  module SharedMethods

    private

    def set_field(attr)
      base = self.is_a?(Class) ? self : singleton_class
      unless base.send :instance_method_already_implemented?, attr
        base.send :define_attribute_method, attr
        self.fields += [attr]
      end
    end

  end

  module ClassMethods

    private

    def field(attr)
      if attr.is_a?(Hash) && attr[:from_spec]
        before_initialize do
          spec[:attributes].each{ |attr| set_field(attr) }
        end
      elsif attr.is_a?(Symbol) || attr.is_a?(String)
        set_field(attr)
      else
        raise Restly::Error::InvalidField, "field must be a symbol or string."
      end
    end

    def exclude_field(name)

      # Remove from the class
      self.fields -= [name]

      # Remove from the instance
      before_initialize do
        self.fields -= [name]
      end

    end

  end

  class FieldSet < Set

    def include?(value)
      super(value.to_sym)
    end

    def <<(value)
      super(value.to_sym)
    end

    def +(other_arry)
      super(other_arry.map(&:to_sym))
    end

    def -(other_arry)
      super(other_arry.map(&:to_sym))
    end

  end

end