module Restly::Associations::Loaders

  def load(parent, options)

    # Merge Options
    options.reverse_merge!(self.options)

    # Authorize and Set Path
    association = authorize(options[:authorize]).with_path(parent, options[:path])

    # Load Collection or Instance
    collection? ? association.load_collection(parent) : association.load_instance(parent)
  end

  def load_collection(parent, association_class = self.association_class)
    raise Restly::Error::AssociationError, "Not a collection" unless collection?
    return [] if embedded?
    Restly::Proxies::Associations::Collection.new(association_class.all, parent)
  end

  def load_instance(parent, association_class = self.association_class)
    raise Restly::Error::AssociationError, "Not an instance" if collection?
    return nil if embedded?
    instance = if parent.attributes.has_key? "#{name}_id"
                 foreign_key = parent.attributes["#{name}_id"]
                 return nil unless foreign_key
                 association_class.find(foreign_key)
               else
                 association_class.instance_from_response association_class.connection.get(association_class.path)
               end
    Restly::Proxies::Associations::Instance.new(instance, parent)
  end

end