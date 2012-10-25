class Restly::Associations::Base

  attr_reader :name, :association_class, :namespace, :polymorphic, :options

  def initialize(owner, name, options={})
    @name = name
    @namespace = options.delete(:namespace) || owner.name.gsub(/::\w+$/, '')
    @polymorphic = options.delete(:polymorphic)
    options[:class_name] ||= name.to_s.classify
    @owner = owner
    @association_class = [@namespace, options.delete(:class_name)].compact.join('::').constantize
    @options = options
  end

  def load(parent, options)
    nil # must be defined on subclasses
  end

  def collection?
    false
  end

  def embedded?
    false
  end

  def valid?(val)
    valid_instances = Array.wrap(val).reject{ |item| item.resource_name == @association_class.resource_name }.empty?
    raise Restly::Error::InvalidObject, "#{val} is not a #{association_class}" unless valid_instances
  end

  def stub(parent, attributes)
    return nil if !parent.is_a?(Restly::Base) || !attributes.present?
    if collection?
      collection = attributes.map{ |item_attrs| association_class.new(item_attrs, loaded: embedded?) }
      Restly::Proxies::Associations::Collection.new(collection, parent)
    else
      instance = association_class.new(attributes, loaded: embedded?)
      Restly::Proxies::Associations::Instance.new(instance, parent)
    end
  end

  def build(parent, attributes = nil, options = {})
    raise NoMethodError, "Build not available for collection." if collection?
    instance = association_class.new(attributes, options)
    instance.write_attribute("#{@owner.resource_name}_id", parent.id) if association_class.method_defined?("#{@owner.resource_name}_id")
    Restly::Proxies::Associations::Instance.new(instance, parent)
  end

  private

  def authorize(klass = @association_class, authorization = nil)
    if (!klass.authorized? && @owner.respond_to?(:authorized?) && @owner.authorized?) || authorization
      klass.authorize(authorization || @owner.connection)
    else
      klass
    end
  end

end