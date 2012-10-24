module Restly::Base::Instance::Attributes

  def update_attributes(attributes)
    self.attributes = attributes
    save
  end

  def attributes=(attributes)
    attributes.each do |k, v|
      write_attribute k, v
    end
  end

  def attributes
    nil_values = fields.inject({}) do |hash, key|
      hash[key] = nil
      hash
    end
    @attributes.reverse_merge!(nil_values)
  end

  def write_attribute(attr, val)
    if fields.include?(attr)
      send("#{attr}_will_change!".to_sym) unless val == @attributes[attr.to_sym] || !@loaded
      @attributes[attr.to_sym] = val
    else
      puts "WARNING: Attribute `#{attr}` not written. ".colorize(:yellow) +
               "To fix this add the following the the model. -- field :#{attr}"
    end
  end

  def read_attribute(attr)
    raise NoMethodError, "undefined method #{attr} for #{klass}" unless fields.include?(attr)
    attributes[attr.to_sym]
  end

  alias :attribute :read_attribute

  def inspect
    inspection = if @attributes
                   fields.collect { |name|
                     "#{name}: #{attribute_for_inspect(name)}"
                   }.compact.join(", ")
                 else
                   "not initialized"
                 end
    "#<#{self.class} #{inspection}>"
  end

  def has_attribute?(attr)
    attribute(attr)
  end

  private

  def attribute_for_inspect(attr_name)
    value = attribute(attr_name)
    if value.is_a?(String) && value.length > 50
      "#{value[0..50]}...".inspect
    else
      value.inspect
    end
  end

  def set_attributes_from_response(response=self.response)
    parsed = response.parsed || {}
    parsed = parsed[resource_name] if parsed.is_a?(Hash) && parsed[resource_name]
    self.attributes = parsed
  end

  def method_missing(m, *args, &block)
    if !!(/(?<attr>\w+)(?<setter>=)?$/ =~ m.to_s) && fields.include?(m)
      case !!setter
        when true
          write_attribute(m, *args)
        when false
          read_attribute(m)
      end
    else
      super(m, *args, &block)
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    !!(/(?<attr>\w+)=?$/ =~ method_name.to_s) && fields.include?(method_name)
  end

end