module Restly::EmbeddedAssociations::ClassMethods

  private

  # Embeds One
  def embeds_resource(name, options = {})
    exclude_field(name)
    self.resource_associations[name] = association = Restly::EmbeddedAssociations::EmbedsOne.new(self, name, options)

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
    exclude_field(name)
    self.resource_associations[name] = association = Restly::EmbeddedAssociations::EmbedsMany.new(self, name, options)

    define_method name do |options={}|
      get_association(name, options)
    end

    define_method "#{name}=" do |value|
      set_association name, value
    end

  end

  def embedded_in(name, options={})
    self.resource_associations[name] = association = Restly::EmbeddedAssociations::EmbeddedIn.new(self, name, options)

    define_method name do |options={}|
      get_association(name, options)
    end

    define_method "#{name}=" do |value|
      set_association name, value
    end

    [:save, :delete, :destroy].each do |method|
      define_method method do
        raise NotImplemented, "Embedded actions have not been implemented."
      end
    end

  end

end