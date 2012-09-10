class OauthResource::Base::Instance < Object
  include ActiveModel::Serialization

  delegate :resource_name, :connection, to: :resource

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
    connection.put(resource.path id, body: @_attributes_)
    self
  end

  def delete
    response = connection.delete(resource.path id)
    response.status == 200 ? true : false
  end

  def error
    connection.error
  end

  def as_json(opts={})
    json = @_attributes_.as_json(except: :resource)
    json = { self.resource.resource_name.to_sym => json } if resource.class.include_root_in_json
    json
  end

  def attributes
    @_attributes_.except(:resource)
  end

end
