module Restly::Base::Instance::Attributes

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
    read_attribute(key)
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
    !!(/(?<attr>\w+)(?<setter>=)?$/ =~ m.to_s) && fields.include?(attr)
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
    if !!(/(?<attr>\w+)(?<setter>=)?$/ =~ m.to_s) && fields.include?(attr)
      case !!setter
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
      send("#{attr}_will_change!".to_sym) unless val == @attributes[attr.to_sym] || !@loaded
      @attributes[attr.to_sym] = Attribute.new(val)

    else
      ActiveSupport::Notifications.instrument("missing_attribute.restly", attr: attr)
    end
  end

  def read_attribute(attr, options={})
    options.reverse_merge!({ autoload: true })
    load! if (key = attr.to_sym) != :id && @attributes[key].nil? && !!options[:autoload] && !loaded? && !exists?
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

  class Attribute < Restly::Proxies::Base

    def initialize(attr)
      @attr = attr
      case @attr
        when String
          type_convert_string
        end
      super(@attr)
    end

    private

    def type_convert_string
      time =    (@attr.to_time rescue nil)
      date =    (@attr.to_date rescue nil)
      # int  =    (@attr.to_i    rescue nil)
      # flt  =    (@attr.to_f    rescue nil)
      @attr = if time.try(:iso8601) == @attr
                time
              elsif date.try(:to_s) == @attr
                date
              #elsif int.try (:to_s) == @attr
              #  int
              #elsif flt.try (:to_s) == @attr
              #  flt
              else
                @attr
      end
    end

  end

end