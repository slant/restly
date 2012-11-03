module Restly::Associations::ClassMethods

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
    self.resource_associations[name] = Restly::Associations::BelongsTo.new(self, name, options)

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
    self.resource_associations[name] = Restly::Associations::HasOne.new(self, name, options)

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
    self.resource_associations[name] = Restly::Associations::HasMany.new(self, name, options)

    define_method name do |options={}|
      get_association(name, options)
    end

    define_method "#{name}=" do |value|
      set_association name, value
    end

  end

end