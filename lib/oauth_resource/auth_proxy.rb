class OauthResource::AuthProxy

  delegate :class, to: :base

  attr_accessor :connection, :permitted_attributes, :path
  attr_reader :resource, :instance

  def initialize(resource_or_instance, token)
    if resource_or_instance.is_a?(Class) && (resource_or_instance.ancestors.collect(&:to_s).include?("OauthResource::Base") || resource_or_instance.name == "OauthResource::Base")
      @resource = resource_or_instance
      self.extend OauthResource::Base::Resource
    elsif resource_or_instance.is_a?(OauthResource::Base)
      @instance = resource_or_instance
      self.permitted_attributes = @instance.permitted_attributes
      self.extend OauthResource::Base::Instance
      initialize(@instance.attributes, @instance.init_options)
    else
      raise OauthResource::Error::InvalidObject, 'Object is not oauth_resource'
    end

    self.connection = tokenize(token)
  end

  private

  def tokenize(token_object)
    if token_object.is_a?(Hash) && token_object.has_key?(:access_token)
      OAuth2::AccessToken.from_hash(client, token_object)
    elsif token_object.is_a?(Rack::Request) && request.headers['HTTP_AUTHORIZATION'] =~ /bearer (?<token>.*)$/i
      OAuth2::AccessToken.from_hash(client, { access_token: token })
    else
      raise InvalidAuthToken, 'Invalid token format!'
    end
  end

  def base
    resource || instance
  end

  def method_missing(m, *args, &block)
    base.send(m, *args, &block)
  end

  def respond_to_missing?(method_name, include_private = false)
    base.respond_to?(method_name, include_private)
  end

end