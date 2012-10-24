module Restly::Associations::EmbeddableResources
  extend ActiveSupport::Autoload

  autoload :EmbeddedIn
  autoload :EmbedsMany
  autoload :EmbedsOne

  # Embeds One
  def embeds_resource(name, options = {})
    exclude_field(name) if ancestors.include?(Restly::Base)
    self.resource_associations[name] = association = EmbedsOne.new(self, name, options)

    define_method name do
      association.build(attributes[name])
    end
  end

  # Embeds Many
  def embeds_resources(name, options = {})
    exclude_field(name) if ancestors.include?(Restly::Base)
    self.resource_associations[name] = association = EmbedsMany.new(self, name, options)

    define_method name do
      ( self.attributes[name] || [] ).map!{ |i| association.build(i) }
    end
  end

end