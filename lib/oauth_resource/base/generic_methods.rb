module OauthResource::Base::GenericMethods

  def authorize(token_object)
    OauthResource::AuthProxy.new self, token_object
  end

  def path_with_format
    [path,format].compact.join('.') if path
  end

end