module Restly::Base::GenericMethods

  def authorize(token_object)
    Restly::Proxies::Authorization.new self, token_object
  end

  def with_params(params={})
    Restly::Proxies::WithParams.new self, params
  end

  def with_path(*args)
    Restly::Proxies::WithPath.new self, *args
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
    false
  end

end