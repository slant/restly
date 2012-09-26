class OauthResource::Proxies::Auth < OauthResource::BaseProxy

  def initialize(receiver, token)
    super(receiver)
    self.connection = OauthResource::Connection.tokenize(client, token)
    connection.cache_options = receiver.cache_options
  end

end