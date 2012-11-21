module Restly::Associations

  ATTR_MATCHER = /(?<attr>\w+)(?<setter>=)?$/

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
    (matched = ATTR_MATCHER.match m) && associations.include?(matched[:attr].to_sym)
  end

  def respond_to?(m, include_private = false)
    respond_to_association?(m) || super
  end

  private

  def association_attributes
    @association_attributes ||= HashWithIndifferentAccess.new
  end

  def loaded_associations
    @loaded_associations ||= HashWithIndifferentAccess.new
  end

  def set_association(attr, val)
    association = self.class.reflect_on_resource_association(attr)
    association.valid?(val)
    association_attributes[attr] = val
  end

  def get_association(attr, options={})
    return loaded_associations[attr] if loaded_associations[attr].present?
    ActiveSupport::Notifications.instrument("load_association.restly", model: self.class.name, association: attr) do
      association = self.class.reflect_on_resource_association(attr)

      loaded_associations[attr] = if (stubbed = association.stub self, association_attributes[attr]).present?
                                    stubbed
                                  elsif (loaded = association.load self, options).present?
                                    loaded
                                  else
                                    association.build(self)
                                  end
    end
  end

  def association_missing(m, *args)
    if (matched = ATTR_MATCHER.match m) && associations.include?(attr = matched[:attr].to_sym)
      case !!matched[:setter]
        when true
          set_association(attr, *args)
        when false
          get_association(attr)
      end
    else
      raise Restly::Error::InvalidAssociation, "Association is invalid"
    end
  end

  def method_missing(m, *args, &block)
    association_missing(m, *args)
  rescue Restly::Error::InvalidAssociation
    super
  end

end