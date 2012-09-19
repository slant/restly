module OauthResource::Base::GenericMethods

  def authorize(token_object)
    OauthResource::Proxies::Auth.new self, token_object
  end

  def with_params(params={})
    OauthResource::Proxies::Params.new self, params
  end

  def path_with_format(*args)
    path = [self.path, args].flatten.compact.join('/')
    [path, format].compact.join('.') if path
  end

  def authorized?
    connection.token.present?
  end

end