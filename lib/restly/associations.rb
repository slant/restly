module Restly::Associations
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :BelongsTo
  autoload :HasMany
  autoload :HasManyThrough
  autoload :HasOne
  autoload :HasOneThrough
  autoload :ClassMethods

  class AssociationsHash < HashWithIndifferentAccess
  end

  class IndifferentSet < Set

    def include?(attr)
      return super unless attr.is_a?(Symbol) || attr.is_a?(String)
      super(attr.to_s) || super(attr.to_sym)
    end

  end

  included do

    include Restly::ConcernedInheritance
    include Restly::NestedAttributes

    class_attribute :resource_associations, instance_reader: false, instance_writer: false

    self.resource_associations = AssociationsHash.new

    inherited do
      self.resource_associations = resource_associations.dup
    end

  end

  def resource_name
    self.class.resource_name
  end

  def associations
    IndifferentSet.new self.class.reflect_on_all_resource_associations.keys.map(&:to_sym)
  end

  def respond_to_association?(m)
    !!(/(?<attr>\w+)(?<setter>=)?$/ =~ m.to_s) && associations.include?(attr.to_sym)
  end

  def respond_to?(m, include_private = false)
    respond_to_association?(m) || super
  end

  private

  def association_attributes
    @association_attributes ||= {}.with_indifferent_access
  end

  def set_association(attr, val)
    association = self.class.reflect_on_resource_association(attr)
    association.valid?(val)
    association_attributes[attr] = val
  end

  def get_association(attr, options={})
    association = self.class.reflect_on_resource_association(attr)
    if (stubbed = association.stub self, association_attributes[attr]).present?
      stubbed
    elsif (loaded = association.load self, options).present?
      loaded
    else
      association.build(self)
    end

  end

  def method_missing(m, *args, &block)
    if !!(/(?<attr>\w+)(?<setter>=)?$/ =~ m.to_s) && associations.include?(m)
      attr = attr.to_sym
      case !!setter
        when true
          set_association(attr, *args)
        when false
          get_association(attr)
      end
    else
      super(m, *args, &block)
    end
  end

end