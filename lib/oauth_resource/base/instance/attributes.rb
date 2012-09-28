module OauthResource::Base::Instance::Attributes

  def update_attributes(attributes)
    self.attributes = attributes
    save
  end

  def attributes=(attributes)
    unused_keys = attributes.keys.select{|k| !attribute_permitted?(k) }.map{|i| ":#{i}" }.join(', ')
    puts "\nWARNING: The keys were not added to the instance. Add the following to the model to make them available: \n\n  resource_attr #{unused_keys}\n\n" if unused_keys.present?
    attributes.select!{|k,v| attribute_permitted?(k) }
    attributes.each do |k,v|
      send("#{k}=".to_sym, v)
    end
  end

  def attributes
    nil_values = permitted_attributes.inject({}) do |hash, key|
      hash[key] = nil
      hash
    end
    @attributes.with_indifferent_access.reverse_merge(nil_values)
  end

  def attribute_permitted?(attr)
    permitted_attributes.to_a.include?(attr.to_sym)
  end

  def attribute(attr)
    attributes[attr.to_sym]
  end

  def inspect
    inspection = if @attributes
                   self.class.permitted_attributes.collect { |name|
                     if has_attribute?(name)
                       "#{name}: #{attribute_for_inspect(name)}"
                     end
                   }.compact.join(", ")
                 else
                   "not initialized"
                 end
    "#<#{self.class} #{inspection}>"
  end

  def has_attribute?(attr)
    attribute(attr)
  end

  def attribute_for_inspect(attr_name)
    value = attribute(attr_name)
    if value.is_a?(String) && value.length > 50
      "#{value[0..50]}...".inspect
    else
      value.inspect
    end
  end

  def set_attributes_from_response
    parsed = response.parsed || {}
    parsed = parsed[resource_name] if parsed[resource_name]
    parsed.select!{ |k,v| attribute_permitted?(k) }
    self.attributes = parsed
  end

  def method_missing(m, *args, &block)
    if !!(/(?<attr>\w+)=$/ =~ m.to_s) && attribute_permitted?(attr) && args.size == 1
      send("#{attr}_will_change!".to_sym) unless args.first == @attributes[attr.to_sym] || !@loaded
      @attributes[attr.to_sym] = args.first
    elsif !!(/(?<attr>\w+)=?$/ =~ m.to_s) && attribute_permitted?(attr)
      attributes[attr.to_sym]
    else
      raise NoMethodError, "undefined method #{m} for #{klass}"
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    !!(/(?<attr>\w+)=?$/ =~ method_name.to_s) && attribute_permitted?(attr)
  end

end