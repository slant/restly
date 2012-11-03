class Restly::Collection < Array
  extend ActiveSupport::Autoload
  include Restly::Base::Resource::Finders
  include Restly::Base::Resource::BatchActions

  delegate :new, :path, :resource_name, :connection, to: :resource

  autoload :Pagination

  attr_reader :resource

  def initialize(resource, array, opts={})
    @resource = resource
    @response = opts[:response]
    array = items_from_response if @response.is_a?(OAuth2::Response)
    super(array)
  end

  def paginate(opts={})
    @pagination_opts = opts
    collection = self.dup
    collection.extend(Restly::Collection::Pagination)
    return page(opts[:page]) unless opts[:page] == current_page && opts[:per_page] == response_per_page
    collection
  end

  def <<(instance)
    raise Restly::Error::InvalidObject, "Object is not an instance of #{resource}" unless instance.is_a?(resource)
    super(instance)
  end

  def serializable_hash(options = nil)
    self.collect do |i|
      i.serializable_hash(options)
    end
  end

  private

  def items_from_response
    parsed = @response.parsed || {}
    parsed = parsed[resource_name.pluralize] if parsed.is_a?(Hash) && parsed[resource_name.pluralize]
    parsed.collect do |instance|
      instance = instance[resource_name] if instance[resource_name]
      resource.new(instance, connection: connection)
    end
  end

end