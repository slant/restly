class OauthResource::Base::Instance

  attr_accessor :attributes

  def initialize(resource, response)
    self.extend OauthResource::Base::ObjectMethods
    @_attributes_ = response || {}
    self.resource = resource
  end

  def update_attributes(attrs={})
    @_attributes_.merge(attrs)
    save
  end

  def save
    resource.connection.put([resource.path, id].join('/'), body: @_attributes_)
    self
  end

  def error
    resource.connection.error
  end

  def as_json(*args)
    super(except: :resource)
  end

end
