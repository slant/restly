module OauthResource::Base::GenericMethods

  def authorize(token_object)
    OauthResource::AuthProxy.new self, token_object
  end

  def path_with_format(*args)
    path = [self.path, args].flatten.compact.join('/')
    [path, format].compact.join('.') if path
  end

  def authorized?
    connection.token.present?
  end

end