module OauthResource::Base::Instance::Attributes

  def update_attributes(attributes)
    self.attributes = attributes
    save
  end

  def attributes=(attributes)
    attributes.each do |k,v|
      send("#{k}=".to_sym, v)
    end
  end

  def attributes
    nil_values = permitted_attributes.inject({}) do |hash, key|
      hash[key] = nil
      hash
    end
    @attributes.reverse_merge(nil_values)
  end

  def attribute_permitted?(attr)
    permitted_attributes.to_a.include?(attr.to_sym)
  end

  def attribute(attr)
    attributes[attr.to_sym]
  end


end