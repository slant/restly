class OauthResource::Proxies::Params < OauthResource::BaseProxy

  def initialize(receiver, params)
    super(receiver)
    self.params.merge!(params)
  end

end