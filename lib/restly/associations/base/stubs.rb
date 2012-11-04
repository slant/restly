module Restly::Associations::Base::Stubs

  # Stubs
  def stub(parent, attributes)
    return nil if !parent.is_a?(Restly::Base) || !attributes.present?
    collection? ? stub_collection(parent, attributes) : stub_instance(parent, attributes)
  end

  def stub_collection(parent, attributes)
    collection = attributes.map{ |item_attrs| association_class.new(item_attrs, loaded: embedded?) }
    Restly::Proxies::Associations::Collection.new(collection, parent)
  end

  def stub_instance(parent, attributes)
    instance = association_class.new(attributes, loaded: embedded?)
    Restly::Proxies::Associations::Instance.new(instance, parent)
  end

end