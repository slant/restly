module Restly::Base::GenericMethods

  def authorize(token_object)
    Restly::Proxies::Auth.new self, token_object
  end

  def with_params(params={})
    Restly::Proxies::Params.new self, params
  end

  def path_with_format(*args)
    path = [self.path, args].flatten.compact.join('/')
    [path, format].compact.join('.') if path
  end

  def format
    client.format
  end

  def authorized?
    connection.token.present?
  end

  def proxied?
    true
  end

end