class OauthResource::Collection < Array
  extend ActiveSupport::Autoload

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
    collection.extend(OauthResource::Collection::Pagination)
    return page(opts[:page]) unless opts[:page] == current_page && opts[:per_page] == response_per_page
    collection
  end

  def <<(instance)
    raise OauthResource::Error::InvalidObject, "Object is not an instance of #{resource}" unless instance.is_a?(resource)
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
    parsed = parsed[resource.resource_name.pluralize] if parsed[resource.resource_name.pluralize]
    parsed.collect do |instance|
      instance = instance[resource.resource_name] if instance[resource.resource_name]
      resource.new(instance, connection: resource.connection)
    end
  end

end