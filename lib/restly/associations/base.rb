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

    # Merge Options
    options.reverse_merge!(self.options)

    # Authorize and Set Path
    association = authorize(options[:authorize]).with_path(parent, options[:path])

    # Load Collection or Instance
    collection? ? association.load_collection(parent) : association.load_instance(parent)
  end

  def load_collection(parent, association_class = self.association_class)
    raise Restly::Error::AssociationError, "Not a collection" unless collection?
    Restly::Proxies::Associations::Collection.new(association_class.all, parent)
  end

  def load_instance(parent, association_class = self.association_class)
    raise Restly::Error::AssociationError, "Not an instance" if collection?
    instance = if (foreign_key = parent.attributes["#{name}_id"])
                 association_class.find(foreign_key)
               else
                 association_class.instance_from_response association_class.connection.get(association_class.path)
               end
    Restly::Proxies::Associations::Instance.new(instance, parent)
  end

  def valid?(val)
    valid_instances = Array.wrap(val).reject{ |item| item.resource_name == @association_class.resource_name }.empty?
    raise Restly::Error::InvalidObject, "#{val} is not a #{association_class}" unless valid_instances
  end

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

  # Build
  def build(parent, attributes = nil, options = {})
    raise NoMethodError, "Build not available for collection." if collection?
    instance = association_class.new(attributes, options)
    instance.write_attribute("#{@owner.resource_name}_id", parent.id) if association_class.method_defined?("#{@owner.resource_name}_id")
    Restly::Proxies::Associations::Instance.new(instance, parent)
  end

  # Modifiers
  def authorize(authorization = nil, association_class=self.association_class)
    duplicate = self.dup
    duplicate.instance_variable_set :@association_class, if (!association_class.authorized? && @owner.respond_to?(:authorized?) && @owner.authorized?) || authorization
                                                           association_class.authorize(authorization || @owner.connection)
                                                         else
                                                           association_class
                                                         end
    duplicate
  end

  def with_path(parent, path = nil, association_class=self.association_class)
    duplicate = self.dup
    duplicate.instance_variable_set :@association_class, if path
                                                           association_class.with_path(path)
                                                         else
                                                           association_class.with_path(association_resource_name, prepend: parent.path)
                                                         end
    duplicate
  end

  private

  def collection?
    false
  end

  def embedded?
    false
  end

  def association_resource_name
    collection? ? association_class.resource_name.pluralize : association_class.resource_name
  end

end