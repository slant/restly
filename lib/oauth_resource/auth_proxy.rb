class OauthResource::AuthProxy

  delegate :class, to: :base

  attr_accessor :connection, :permitted_attributes, :path
  attr_reader :resource, :instance

  def initialize(resource_or_instance, token)
    if resource_or_instance.is_a?(Class) && (resource_or_instance.ancestors.include?("OauthResource::Base") || resource_or_instance.name == "OauthResource::Base")
      @resource = resource_or_instance
      self.extend OauthResource::Base::ResourceActions
    elsif resource_or_instance.is_a?(OauthResource::Base)
      @instance = resource_or_instance
      self.permitted_attributes = @instance.permitted_attributes
      self.extend OauthResource::Base::InstanceActions
      initialize(@instance.attributes, @instance.init_options)
    else
      raise OauthResource::Error::InvalidObject, 'Object is not oauth_resource'
    end

    self.connection = tokenize(token)

  end

  def authorized?
    !!connection.token
  end

  private :authorize

  private

  def tokenize(token_object)
    if token_object.is_a?(Hash) && token_object.has_key?(:token)
      OAuth2::AccessToken.from_hash(client, token_object)
    elsif token_object.is_a?(Rack::Request) && request.headers['HTTP_AUTHORIZATION'] =~ /bearer (?<token>.*)$/i
      OAuth2::AccessToken.from_hash(client, { token: token })
    else
      raise InvalidAuthToken, 'Invalid token format!'
    end
  end

  def base
    resource || instance
  end

  def method_missing(m, *args, &block)
    if resource
      resource.send(m, *args, &block)
    else
      super
    end
  end

end