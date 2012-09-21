class OauthResource::Proxies::Auth < OauthResource::BaseProxy

  def initialize(requester, token)
    super(requester)
    self.connection = tokenize(token)
  end

  private

  def tokenize(token_object)
    if token_object.is_a?(Hash) && token_object.has_key?(:access_token)
      OAuth2::AccessToken.from_hash(client, token_object)
    elsif token_object.is_a?(Rack::Request) && /\w+ (?<token>\w+)$/i =~ request.headers['HTTP_AUTHORIZATION']
      OAuth2::AccessToken.from_hash(client, { access_token: token })
    elsif token_object.is_a?(OAuth2::AccessToken)
      token_object
    else
      raise OauthResource::Error::InvalidToken, 'Invalid token format!'
    end
  end

end