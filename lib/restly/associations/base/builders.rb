module Restly::Associations::Base::Builders

  # Build
  def build(parent, attributes = nil, options = {})

    # Merge Options
    options.reverse_merge!(self.options)

    # Authorize and Set Path
    association = authorize(options[:authorize]).with_path(parent, options[:path])

    collection? ? association.build_collection(parent) : association.build_instance(parent, attributes)
  end

  def build_instance(parent, attributes)
    instance = association_class.new(attributes, options)
    instance.write_attribute("#{@owner.resource_name}_id", parent.id) if association_class.method_defined?("#{@owner.resource_name}_id")
    Restly::Proxies::Associations::Instance.new(instance, parent)
  end

  def build_collection(parent)
    Restly::Proxies::Associations::Collection.new(Restly::Collection.new(association_class), parent)
  end

end