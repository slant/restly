module Restly::Associations::Base::Loaders

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
    collection = if embedded?
                   []
                 else
                   association_class.all
                 end

    Restly::Proxies::Associations::Collection.new(collection, parent)
  end

  def load_instance(parent, association_class = self.association_class)
    raise Restly::Error::AssociationError, "Not an instance" if collection?
    return nil if embedded?
    foreign_key = options[:foreign_key] || "#{name}_id"
    instance = if parent.attributes.has_key? foreign_key
                 id = parent.attributes[foreign_key]
                 return nil unless id
                 association_class.find(id)
               else
                 association_class.instance_from_response association_class.connection.get(association_class.path_with_format)
               end
    Restly::Proxies::Associations::Instance.new(instance, parent)
  end


end
