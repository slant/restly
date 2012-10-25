module Restly::Associations
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :BelongsTo
  autoload :HasMany
  autoload :HasManyThrough
  autoload :HasOne
  autoload :HasOneThrough
  autoload :EmbeddableResources

  class AssociationsSet < HashWithIndifferentAccess
  end

  class IndifferentSet < Set

    def include?(attr)
      return super unless attr.is_a?(Symbol) || attr.is_a?(String)
      super(attr.to_s) || super(attr.to_sym)
    end

  end

  included do

    include Restly::ConcernedInheritance
    extend  EmbeddableResources if self == Restly::Base
    include Restly::NestedAttributes

    delegate :resource_name, to: :klass
    class_attribute :resource_associations, instance_reader: false, instance_writer: false

    attr_reader :association_attributes

    self.resource_associations = AssociationsSet.new

    inherited do
      self.resource_associations = resource_associations.dup
    end

  end

  def associations
    IndifferentSet.new klass.reflect_on_all_resource_associations.keys.map(&:to_sym)
  end

  def set_association(attr, val)
    association = klass.reflect_on_resource_association(attr)
    association.valid?(val)
    @association_attributes[attr] = val
  end

  def get_association(attr, options={})
    association = klass.reflect_on_resource_association(attr)
    (@association_attributes ||= {}.with_indifferent_access)[attr] || set_association(attr, association.load(self, options))
  end

  def respond_to_association?(m)
    !!(/(?<attr>\w+)(?<setter>=)?$/ =~ m.to_s) && associations.include?(attr.to_sym)
  end

  def respond_to?(m, include_private = false)
    respond_to_association?(m) || super
  end

  private

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

  def klass
    self.class
  end

  module ClassMethods

    def resource_name
      name.gsub(/.*::/,'').underscore
    end

    def reflect_on_resource_association(association_name)
      reflect_on_all_resource_associations[association_name]
    end

    def reflect_on_all_resource_associations
      resource_associations
    end

    private

    # Belongs to
    def belongs_to_resource(name, options = {})
      exclude_field(name) if ancestors.include?(Restly::Base)
      self.resource_associations[name] = association = BelongsTo.new(self, name, options)

      define_method name do |options={}|
        get_association(name, options)
      end

      define_method "#{name}=" do |value|
        set_association name, value
      end

    end

    # Has One
    def has_one_resource(name, options = {})
      exclude_field(name) if ancestors.include?(Restly::Base)
      self.resource_associations[name] = association = HasOne.new(self, name, options)

      define_method name do |options={}|
        get_association(name, options)
      end

      define_method "#{name}=" do |value|
        set_association name, value
      end

    end

    # Has One
    def has_many_resources(name, options = {})
      exclude_field(name) if ancestors.include?(Restly::Base)
      self.resource_associations[name] = association = HasMany.new(self, name, options)

      define_method name do |options={}|
        get_association(name, options)
      end

      define_method "#{name}=" do |value|
        set_association name, value
      end

    end

  end

end