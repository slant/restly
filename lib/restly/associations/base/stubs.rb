module Restly::Associations::Base::Stubs

  # Stubs
  def stub(parent, attributes)
    return nil if !parent.is_a?(Restly::Base) || !attributes.present?
    collection? ? stub_collection(parent, attributes) : stub_instance(parent, attributes)
  end

  def stub_collection(parent, attributes)
    collection = attributes.map do |item|
      if item.respond_to? :attributes
        item
      else
        association_class.new(item, loaded: embedded?)
      end
    end
    Restly::Proxies::Associations::Collection.new(collection, parent)
  end

  def stub_instance(parent, attributes)
    instance = association_class.new(attributes, loaded: embedded?)
    Restly::Proxies::Associations::Instance.new(instance, parent)
  end

end