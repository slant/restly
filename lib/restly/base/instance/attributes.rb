module Restly::Base::Instance::Attributes

  ATTR_MATCHER = /(?<attr>\w+)(?<setter>=)?$/

  def update_attributes(attributes)
    self.attributes = attributes
    save
  end

  def attributes=(attributes)
    attributes.each do |k, v|
      self[k] = v
    end
  end

  def attributes
    fields.reduce(HashWithIndifferentAccess.new) do |hash, key|
      hash[key] = read_attribute(key, autoload: false)
      hash
    end
  end

  def attribute(key, options={})
    read_attribute(key, options)
  end

  def []=(key, value)
    send "#{key}=", value
  end

  def [](key)
    send key
  end

  def has_attribute?(attr)
    fields.include?(attr) && attribute(attr)
  end

  def respond_to_attribute?(m)
    (matched = ATTR_MATCHER.match m) && fields.include?(matched[:attr])
  end

  def respond_to?(m, include_private = false)
    respond_to_attribute?(m) || super
  end

  def inspect
    inspection = if @attributes
                   fields.map { |name|
                     "#{name}: #{attribute_for_inspect(name)}"
                   }.compact.join(", ")
                 else
                   "not initialized"
                 end
    "#<#{self.class} #{inspection}>"
  end

  private

  def attribute_missing(m, *args)
    if (matched = ATTR_MATCHER.match m) && fields.include?(attr = matched[:attr].to_sym)
      case !!matched[:setter]
        when true
          write_attribute(attr, *args)
        when false
          read_attribute(attr, *args)
      end
    else
      raise Restly::Error::InvalidAttribute, "Attribute does not exist!"
    end
  end

  def method_missing(m, *args, &block)
    attribute_missing(m, *args)
  rescue Restly::Error::InvalidAttribute
    super
  end

  def write_attribute(attr, val)
    if fields.include?(attr)
      send("#{attr}_will_change!") if val != read_attribute(attr) && loaded?
      @attributes[attr.to_sym] = convert_attr_type(val)
    else
      ActiveSupport::Notifications.instrument("missing_attribute.restly", attr: attr)
    end
  end

  def read_attribute(attr, options={})
    options.reverse_merge!({ autoload: true })

    # Try and get the attribute if the item is not loaded
    if initialized? && attr.to_sym != :id && attribute_not_loaded?(attr) && !!options[:autoload] && !loaded? && exists?
      load!
    end

    @attributes[attr.to_sym]
  end

  def attribute_for_inspect(attr_name)
    value = attribute(attr_name, autoload: false)
    if value.is_a?(String) && value.length > 50
      "#{value[0..50]}...".inspect
    else
      value.inspect
    end
  end

  def set_attributes_from_response(response=self.response)
    self.attributes = parsed_response(response)
  end

  def attribute_loaded?(attr)
    @attributes.has_key? attr
  end

  def attribute_not_loaded?(attr)
    !attribute_loaded?(attr)
  end

  def convert_attr_type(val)
    time = (val.to_time rescue nil)
    date = (val.to_date rescue nil)
    if time.try(:iso8601) == val
      time
    elsif date.try(:to_s) == val
      date
    else
      val
    end
  end

end