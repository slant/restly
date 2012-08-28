class OauthResource::Base::Collection

  def initialize( resource, response )
    self.extend OauthResource::Base::ObjectMethods
    @_attributes_ = response || {}
    self.resource = resource
  end

end
