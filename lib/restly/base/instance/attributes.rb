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
    fields.reduce(HashWithIndifferentAccess.new) do |hash, key|
      hash[key] = read_attribute key, autoload: false
      hash
    end
  end

  def write_attribute(attr, val)
    if fields.include?(attr)
      send("#{attr}_will_change!".to_sym) unless val == @attributes[attr.to_sym] || !@loaded
      @attributes[attr.to_sym] = Attribute.new(val)

    elsif (association = self.class.reflect_on_resource_association attr).present?
      set_association attr, association.stub(self, val) unless (@association_attributes ||= {}.with_indifferent_access)[attr].present?

    else
      puts "WARNING: Attribute `#{attr}` not written. ".colorize(:yellow) +
               "To fix this add the following the the model. -- field :#{attr}"
    end
  end

  def read_attribute(attr, options={})
    options.reverse_merge!({autoload: true})
    if @attributes[attr.to_sym].nil? && !!options[:autoload] && !loaded?
      load!
      read_attribute(attr)
    else
      @attributes[attr.to_sym]
    end
  end

  alias :attribute :read_attribute

  def has_attribute?(attr)
    attribute(attr)
  end

  def respond_to_attribute?(m)
    !!(/(?<attr>\w+)(?<setter>=)?$/ =~ m.to_s) && associations.include?(attr)
  end

  def respond_to?(m, include_private = false)
    respond_to_attribute?(m) || super
  end

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

  private

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

  def method_missing(m, *args, &block)
    if !!(/(?<attr>\w+)(?<setter>=)?$/ =~ m.to_s) && fields.include?(attr)
      case !!setter
        when true
          write_attribute(attr, *args)
        when false
          read_attribute(attr)
      end
    else
      super(m, *args, &block)
    end
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