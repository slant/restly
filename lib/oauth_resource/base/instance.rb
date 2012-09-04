class OauthResource::Base::Instance

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

  def inspect
    to_s.sub />$/, " #{@_attributes_.except(:resource).to_s}>"
  end

  def as_json(*args)
    super(except: :resource)
  end

end
