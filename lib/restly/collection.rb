class Restly::Collection < Array
  extend ActiveSupport::Autoload
  autoload :Pagination
  autoload :ErrorHandling

  include Restly::Base::Resource::Finders
  include Restly::Base::Resource::BatchActions
  include Restly::Base::GenericMethods
  include ErrorHandling
  include Pagination

  delegate :resource_name, :new, :client, to: :resource

  attr_reader :resource, :response

  def initialize(resource, array=[], opts={})
    ActiveSupport::Notifications.instrument("load_collection.restly", model: resource.name) do
      @errors = []
      @resource = resource
      @connection
      if opts[:response]
        set_response(opts[:response])
      else
        replace array
      end
    end
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

  def <<(instance)
    raise Restly::Error::InvalidObject, "Object is not an instance of #{resource}" unless accepts?(instance)
    super(instance)
  end

  def replace(array)
    array.each do |instance|
      raise Restly::Error::InvalidObject, "Object is not an instance of #{resource}" unless accepts?(instance)
    end
    super
  end

  def reload!
    replace collection_from_response(connection.get path)
  end

  private

  def set_response(response)
    raise Restly::Error::InvalidResponse unless response.is_a? OAuth2::Response
    @response = response
    if response.try(:body)
      if response_has_errors?(response)
        set_errors_from_response
      else
        set_items_from_response
      end
    end
  end

  def serializable_hash(options = nil)
    self.map do |i|
      i.serializable_hash(options)
    end
  end

  def set_items_from_response(response=self.response)
    parsed_response(response).reduce(self) do |collection, instance|
      instance = instance[resource_name] if instance[resource_name]
      collection << resource.new(instance, connection: connection, loaded: false)
    end
  end

  def accepts?(instance)
    instance.class.name == resource.name
  end

  def parsed_response(response=self.response)
    return {} unless response
    parsed = response.parsed || {}
    if parsed.is_a?(Hash) && parsed[resource_name.pluralize]
      parsed[resource_name.pluralize]
    elsif parsed.is_a?(Hash)
      parsed.with_indifferent_access
    else
      parsed
    end
  end

end