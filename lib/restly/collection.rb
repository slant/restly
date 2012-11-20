class Restly::Collection < Array
  extend ActiveSupport::Autoload
  autoload :Pagination

  include Restly::Base::Resource::Finders
  include Restly::Base::Resource::BatchActions
  include Restly::Base::GenericMethods

  delegate :resource_name, :new, :client, to: :resource

  attr_reader :resource

  def initialize(resource, array=[], opts={})
    @resource = resource
    @response = opts[:response]
    @connection
    array = items_from_response if @response.is_a?(OAuth2::Response)
    super(array)
  end

  [:path, :connection, :params].each do |attr|
    define_method attr do
      instance_variable_get(:"@#{attr}") || resource.send(attr)
    end

    define_method "#{attr}=" do |val|
      instance_variable_set(:"@#{attr}", val)
    end
  end

  def create(*args)
    self << instance = super
    instance
  end

  def map(*args)
    initialize resource, super
  end

  alias :collect :map

  #def paginate(opts={})
  #  @pagination_opts = opts
  #  collection = self.dup
  #  collection.extend(Restly::Collection::Pagination)
  #  return page(opts[:page]) unless opts[:page] == current_page && opts[:per_page] == response_per_page
  #  collection
  #end

  def <<(instance)
    raise Restly::Error::InvalidObject, "Object is not an instance of #{resource}" unless accepts?(instance)
    super(instance)
  end

  def reload!
    replace collection_from_response(connection.get path)
  end

  private

  def serializable_hash(options = nil)
    self.collect do |i|
      i.serializable_hash(options)
    end
  end

  def items_from_response
    parsed = @response.parsed || {}
    parsed = parsed[resource_name.pluralize] if parsed.is_a?(Hash) && parsed[resource_name.pluralize]
    parsed.collect do |instance|
      instance = instance[resource_name] if instance[resource_name]
      resource.new(instance, connection: connection, loaded: false)
    end
  end

  def accepts?(instance)
    instance.class.name == resource.name
  end

end