class OauthResource::Base::Instance < Object

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
    resource.connection.put(resource.path id, body: @_attributes_)
    self
  end

  def delete
    response = resource.connection.delete(resource.path id)
    response.status == 200 ? true : false
  end

  def error
    resource.connection.error
  end

  def as_json(*args)
    { self.resource.resource_name.to_sym => @_attributes_.as_json(except: :resource) }
  end

end
