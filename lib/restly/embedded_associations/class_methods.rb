module Restly::Associations::EmbeddedAssociations

  # Embeds One
  def embeds_resource(name, options = {})
    exclude_field(name) if ancestors.include?(Restly::Base)
    self.resource_associations[name] = association = EmbedsOne.new(self, name, options)

    define_method name do |options={}|
      return get_association(name) if get_association(name).present?
      set_association name, association.stub(self)
    end

    define_method "#{name}=" do |value|
      set_association name, value
    end

  end

  # Embeds Many
  def embeds_resources(name, options = {})
    exclude_field(name) if ancestors.include?(Restly::Base)
    self.resource_associations[name] = association = EmbedsMany.new(self, name, options)

    define_method name do |options={}|
      get_association(name, options)
    end

    define_method "#{name}=" do |value|
      set_association name, value
    end

  end

  def embedded_in(name, options={})
    self.resource_associations[name] = association = EmbeddedIn.new(self, name, options)

    define_method name do |options={}|
      get_association(name, options)
    end

    define_method "#{name}=" do |value|
      set_association name, value
    end
  end

end