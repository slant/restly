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

  class AssociationHash < HashWithIndifferentAccess
  end

  included do

    extend EmbeddableResources if self == Restly::Base
    include Restly::NestedAttributes

    delegate :resource_name, to: :klass
    class_attribute :resource_associations, instance_reader: false, instance_writer: false
    self.resource_associations = AssociationHash.new

    inherited do
      self.resource_associations = resource_associations.dup
    end

  end

  def stub_associations_from_response(response=self.response)
    parsed = response.parsed || {}
    parsed = parsed[resource_name] if parsed.is_a?(Hash) && parsed[resource_name]
    associations = parsed.select{ |i| klass.reflect_on_all_resource_associations.keys.include?(i) }
    associations.each do |relationship|
      relationship.collection?
    end
  end

  def klass
    self.class
  end

  module ClassMethods

    def resource_name
      name.gsub(/.*::/,'').underscore
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
        association.find_with_parent(self, options)
      end
    end

    # Has One
    def has_one_resource(name, options = {})
      exclude_field(name) if ancestors.include?(Restly::Base)
      self.resource_associations[name] = association = HasOne.new(self, name, options)
      define_method name do |options={}|
        association.scope_with_parent(self, options)
      end
    end

    # Has One
    def has_many_resources(name, options = {})
      exclude_field(name) if ancestors.include?(Restly::Base)
      self.resource_associations[name] = association = HasMany.new(self, name, options)
      define_method name do |options={}|
        association.scope_with_parent(self, options)
      end
    end


    def reflect_on_resource_association(association_name)
      reflect_on_all_resource_associations[association_name]
    end

  end

end